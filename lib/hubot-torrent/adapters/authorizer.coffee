class Authorizer
  _userAgent: 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:23.0) Gecko/20100101 Firefox/23.0'

  constructor: (@_granter) ->
    this._checkAuthData()

    @_http = require('http')

  authorize: (resolve, reject) ->
    opts = @_granter.authorizeOptions()
    opts.headers['User-Agent'] = @_userAgent

    req = @_http.request(opts)

    req.on(
      'response'
      (res) =>
        @_authData = @_granter.parseAuthCode(res)
        resolve()
    )

    req.on(
      'error'
      (e) ->
        throw e.message
    )

    req.write(@_granter.authorizeData())

    req.end()

  authorizeData: ->
    @_authData

  _checkAuthData: ->
    requiredEnvVars = @_granter.requiredEnvVars()

    for envVar in requiredEnvVars
      unless process.env[envVar]
        vars = for envVar in requiredEnvVars
          "export #{envVar}=\"your value\""

        throw "To use #{@_granter.name()} adapter you need to define credentials to the service. " +
          "Please, add following environment variables to ~/.bashrc file\n" +
          vars.join("\n")

module.exports = Authorizer