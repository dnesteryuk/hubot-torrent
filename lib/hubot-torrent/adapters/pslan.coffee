BaseAdapter = require('./base')

class PslanAdapter extends BaseAdapter
  trackerHost: 'www.pslan.com'
  pathToLogin: '/takelogin.php'

  login: ->
    data = @querystring.stringify(
      username: process.env.PSLAN_USERNAME
      password: process.env.PSLAN_PASSWORD
    )

    options =
      host:   @trackerHost
      port:   80
      method: 'POST'
      path:   @pathToLogin
      headers:
        'Content-Type':   'application/x-www-form-urlencoded'
        'Content-Length': data.length
        'User-Agent':     @userAgent

    super options, data

  doSearch: ->
    options =
      host:   @trackerHost
      port:   80
      method: 'GET'
      path:   "/browse.php?search=#{@query}"
      headers:
        'Cookie':     @authCode
        'User-Agent': @userAgent

    super options

  parseResp: (html) ->
    data = []

    jsdom = require('jsdom')

    #console.info(html)

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

          this.emit('result', data)
    )

  _parseAuthCode: (res) ->
    cookie = res.headers['set-cookie']

    uid = cookie[2].match(/uid=(\d+)/)[0]
    pass = cookie[3].match(/pass=([\w\d]+)/)[0]

    @authCode = "#{uid}; #{pass}"

module.exports = PslanAdapter