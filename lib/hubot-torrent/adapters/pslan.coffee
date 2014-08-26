Promise     = require('promise')
BaseAdapter = require('./base')
Parser      = require('./pslan/parser')

class PslanAdapter extends BaseAdapter
  _trackerHost: 'www.pslan.com'

  parseResp: (html) =>
    new Parser(html, this).parse()

  downloadTorrentFile: (id) ->
    options =
      host:   @trackerHost
      port:   80
      method: 'GET'
      path:   "/#{id}"
      headers:
        'Cookie': @_authorizer.authorizeData()

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
              host:   @_trackerHost
              port:   80
              method: 'GET'
              path:   '/' + href.replace(/downloadit/, 'download')
              headers:
                'Accept-Encoding': 'gzip,deflate,sdch'
                'Content-Length':  0
                'Cookie': @_authorizer.authorizeData()

            super options
        )
    )

  _searchOptions: ->
    host:     @_trackerHost
    port:     80
    method:   'GET'
    path:     "/browse.php?search=#{@query}"
    headers:
      'Cookie': @_authorizer.authorizeData()

  _authorizeGranter: ->
    AuthorizeGranter = require('./pslan/authorize_granter')

    new AuthorizeGranter()

module.exports = PslanAdapter