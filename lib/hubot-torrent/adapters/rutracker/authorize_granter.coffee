class AuthorizeGranter
  _trackerHost: 'rutracker.org'
  _pathToLogin: '/forum/login.php'

  _requiredEnvVars: [
    'RUTRACKER_LOGIN'
    'RUTRACKER_PASSWORD'
  ]

  trackerName: ->
    'Rutracker'

  parseAuthCode: (res) ->
    res.headers['set-cookie'][0].match(/bb_data=([\w-\d]+);/)[0].replace(';', '')

  authorizeData: ->
    querystring = require('querystring')

    querystring.stringify(
      login_username: process.env.RUTRACKER_LOGIN
      login_password: process.env.RUTRACKER_PASSWORD
      redirect:       'index.php'
      login:          'Вход'
    )

  authorizeOptions: ->
    host:   "login.#{@_trackerHost}"
    port:   80
    method: 'POST'
    path:   '/forum/login.php'
    headers:
      'Content-Type':   'application/x-www-form-urlencoded'
      'Content-Length': this.authorizeData().length
      'Referer':        "http://login.#{@_trackerHost}#{@_pathToLogin}"

  requiredEnvVars: ->
    @_requiredEnvVars

module.exports = AuthorizeGranter