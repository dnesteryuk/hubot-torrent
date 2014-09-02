Promise          = require('promise')
BaseAdapter      = require('./base')

Authorizer       = require('./authorizer')

Parser           = require('./rutracker/parser')
AuthorizeGranter = require('./rutracker/authorize_granter')

class RutrackerAdapter extends BaseAdapter
  _trackerHost: 'rutracker.org'

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
        'Cookie':          "#{@_authorizer.authorizeData()}; bb_dl=#{id}"

    super options

  _searchOptions: ->
    host:   @_trackerHost
    port:   80
    method: 'GET'
    path:   "/forum/tracker.php?nm=#{@query}"
    headers:
      'Cookie': @_authorizer.authorizeData()

RutrackerAdapter.build = ->
  authorizer = new Authorizer(
    new AuthorizeGranter()
  )

  new RutrackerAdapter(authorizer)

module.exports = RutrackerAdapter