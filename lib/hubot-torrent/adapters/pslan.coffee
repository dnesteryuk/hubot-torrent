Promise     = require('promise')
BaseAdapter = require('./base')
Parser      = require('./pslan/parser')

class PslanAdapter extends BaseAdapter
  trackerName: 'Pslan'

  trackerHost: 'www.pslan.com'
  pathToLogin: '/takelogin.php'

  requiredEnvVars: [
    'PSLAN_USERNAME'
    'PSLAN_PASSWORD'
  ]

  parseResp: (html) =>
    new Parser(html, this).parse()

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
    host:     @trackerHost
    port:     80
    method:   'GET'
    path:     "/browse.php?search=#{@query}"
    headers:
      'Cookie':     @authCode
      'User-Agent': @userAgent

module.exports = PslanAdapter