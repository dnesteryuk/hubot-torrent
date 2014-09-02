class AuthorizeGranter
  _trackerHost: 'www.pslan.com'
  _pathToLogin: '/takelogin.php'

  _requiredEnvVars: [
    'PSLAN_USERNAME'
    'PSLAN_PASSWORD'
  ]

  trackerName: ->
    'Pslan'

  parseAuthCode: (res) ->
    cookie = res.headers['set-cookie']

    uid  = cookie[2].match(/uid=(\d+)/)[0]
    pass = cookie[3].match(/pass=([\w\d]+)/)[0].replace(';', '')

    "#{uid}; #{pass}"

  authorizeData: ->
    querystring = require('querystring')

    querystring.stringify(
      username: process.env.PSLAN_USERNAME
      password: process.env.PSLAN_PASSWORD
    )

  authorizeOptions: ->
    host:   @_trackerHost
    port:   80
    method: 'POST'
    path:   @_pathToLogin
    headers:
      'Content-Type':   'application/x-www-form-urlencoded'
      'Content-Length': this.authorizeData().length

  requiredEnvVars: ->
    @_requiredEnvVars

module.exports = AuthorizeGranter