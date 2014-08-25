Promise     = require('promise')
BaseAdapter = require('./base')
Parser      = require('./rutracker/parser')

class RutrackerAdapter extends BaseAdapter
  trackerName: 'Rutracker'

  trackerHost: 'rutracker.org'
  pathToLogin: '/forum/login.php'

  requiredEnvVars: [
    'RUTRACKER_LOGIN'
    'RUTRACKER_PASSWORD'
  ]

  parseResp: (html) =>
    new Parser(html, this).parse()

  downloadTorrentFile: (id) ->
    options =
      host:   'dl.rutracker.org'
      port:   80
      method: 'POST'
      path:   "/forum/dl.php?t=#{id}"
      headers:
        'Accept-Encoding': 'gzip,deflate,sdch'
        'Content-Type':    'application/x-www-form-urlencoded'
        'Content-Length':  0
        'Cookie':          "#{@authCode}; bb_dl=#{id}"
        'User-Agent':      @userAgent

    super options

  _parseAuthCode: (res) ->
    @authCode = res.headers['set-cookie'][0].match(/bb_data=([\w-\d]+);/)[0].replace(';', '')

  _loginData: ->
    @querystring.stringify(
      login_username: process.env.RUTRACKER_LOGIN
      login_password: process.env.RUTRACKER_PASSWORD
      redirect:       'index.php'
      login:          'Вход'
    )

  _loginOptions: ->
    host:   "login.#{@trackerHost}"
    port:   80
    method: 'POST'
    path:   '/forum/login.php'
    headers:
      'Content-Type':   'application/x-www-form-urlencoded'
      'Content-Length': @_loginData().length
      'Referer':        "http://login.#{@trackerHost}#{@pathToLogin}"
      'User-Agent':     @userAgent

  _searchOptions: ->
    host:   @trackerHost
    port:   80
    method: 'GET'
    path:   "/forum/tracker.php?nm=#{@query}"
    headers:
      'Cookie':     @authCode
      'User-Agent': @userAgent

module.exports = RutrackerAdapter