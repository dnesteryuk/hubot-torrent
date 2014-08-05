Promise     = require('promise')
Buffer      = require('buffer').Buffer
Iconv       = require('iconv').Iconv
BaseAdapter = require('./base')

class PslanAdapter extends BaseAdapter
  trackerName: 'Pslan'

  trackerHost: 'www.pslan.com'
  pathToLogin: '/takelogin.php'

  requiredEnvVars: [
    'PSLAN_USERNAME'
    'PSLAN_PASSWORD'
  ]

  parseResp: (html) =>
    data = []

    jsdom = require('jsdom')

    new Promise(
      (resolve) =>
        iconv = new Iconv('windows-1251', 'utf-8')
        html  = new Buffer(html, 'binary')
        html  = iconv.convert(html).toString()

        jsdom.env(
          html
          ['http://code.jquery.com/jquery.js']
          (errors, window) =>
            if errors
              console.error(errors)
            else
              col = window.$('#highlighted')

              rows = col.find('tr')

              window.$.each(
                rows
                (index, row) =>
                  cells    = window.$(row).find('td')
                  nameCell = cells.eq(1)

                  pathToDetails = nameCell.find('a').attr('href')

                  seedsLeeches = cells.eq(5).find('b')

                  data.push(
                    name:             nameCell.find('a b').text()
                    torrent_file_url: pathToDetails
                    size:             cells.eq(4).text().replace('<br>', '')
                    seeds:            seedsLeeches.eq(0).find('a font').text()
                    tracker:          this
                  )
              )

              resolve(data)
        )
      )

  downloadTorrentFile: (id) ->
    options =
      host:   @trackerHost
      port:   80
      method: 'GET'
      path:   "/#{id}"
      headers:
        'Cookie':     @authCode
        'User-Agent': @userAgent

    this._doRequest(
      options
      (html) =>
        jsdom = require('jsdom')

        jsdom.env(
          html
          ['http://code.jquery.com/jquery.js']
          (errors, window) =>
            href = window.$('.index').attr('href')

            options =
              host:   @trackerHost
              port:   80
              method: 'GET'
              path:   '/' + href.replace(/downloadit/, 'download')
              headers:
                'Accept-Encoding': 'gzip,deflate,sdch'
                'Content-Length':  0
                'Cookie':          @authCode
                'User-Agent':      @userAgent

            super options
        )
    )

  _parseAuthCode: (res) ->
    cookie = res.headers['set-cookie']

    uid  = cookie[2].match(/uid=(\d+)/)[0]
    pass = cookie[3].match(/pass=([\w\d]+)/)[0].replace(';', '')

    @authCode = "#{uid}; #{pass}"

  _loginData: ->
    @querystring.stringify(
      username: process.env.PSLAN_USERNAME
      password: process.env.PSLAN_PASSWORD
    )

  _loginOptions: ->
    host:   @trackerHost
    port:   80
    method: 'POST'
    path:   @pathToLogin
    headers:
      'Content-Type':   'application/x-www-form-urlencoded'
      'Content-Length': @_loginData().length
      'User-Agent':     @userAgent

  _searchOptions: ->
    query = @querystring.stringify(@query)

    host:     @trackerHost
    port:     80
    method:   'GET'
    path:     "/browse.php?search=#{query}"
    headers:
      'Cookie':     @authCode
      'User-Agent': @userAgent

module.exports = PslanAdapter