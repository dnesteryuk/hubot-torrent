class Authorizer
  pathToLogin: '/takelogin.php'
  trackerHost: 'www.pslan.com'

  userAgent: 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:23.0) Gecko/20100101 Firefox/23.0'

  requiredEnvVars: [
    'PSLAN_USERNAME'
    'PSLAN_PASSWORD'
  ]

  trackerName: 'Pslan'

  constructor: ->
    this._checkAuthData()

    @_http        = require('http')
    @_querystring = require('querystring')

  authorize: (resolve, reject) ->
    req = @_http.request(
      this._loginOptions()
    )

    req.on(
      'response'
      (res) =>
        this._parseAuthCode(res)
        resolve()
    )

    req.on(
      'error'
      (e) ->
        throw e.message
    )

    req.write(this._loginData())

    req.end()

  authorizedData: ->
    @_authCode

  _parseAuthCode: (res) ->
    cookie = res.headers['set-cookie']

    uid  = cookie[2].match(/uid=(\d+)/)[0]
    pass = cookie[3].match(/pass=([\w\d]+)/)[0].replace(';', '')

    @_authCode = "#{uid}; #{pass}"

  _loginData: ->
    @_querystring.stringify(
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

  _checkAuthData: ->
    for envVar in @requiredEnvVars
      unless process.env[envVar]
        vars = for envVar in @requiredEnvVars
          "export #{envVar}=\"your value\""

        throw "To use #{@trackerName} adapter you need to define credentials to the service. " +
          "Please, add following environment variables to ~/.bashrc file\n" +
          vars.join("\n")

module.exports = Authorizer