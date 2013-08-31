EventEmitter = require('events').EventEmitter

class BaseAdapter extends EventEmitter
  userAgent: 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:23.0) Gecko/20100101 Firefox/23.0'

  constructor: ->
    @http        = require('http')
    @querystring = require('querystring')

  search: (query) ->
    @query = query

    this.login()

  login: (requestOptions, data) ->
    req = @http.request(
      requestOptions
    )

    req.on(
      'response'
      (res) =>
        this._parseAuthCode(res)
        this.doSearch()
    )

    req.on(
      'error'
      (e) ->
        console.log("Got error: #{e.message}")
    )

    req.write(data)

    req.end()

  doSearch: (requestOptions) ->
    this._doRequest(
      requestOptions
      (html) =>
        this.parseResp(html)
    )

  downloadTorrentFile: (requestOptions) ->
    torrentFile = '/tmp/test.torrent'

    fs = require('fs')

    if fs.existsSync(torrentFile)
      fs.unlink(torrentFile)

    file = fs.createWriteStream(torrentFile)

    req = @http.request(
      requestOptions
    )

    req.on(
      'response'
      (res) =>
        res.pipe(file)

        res.on(
          'end'
          =>
            file.end()
            this.emit('torrent:file', torrentFile)
        )
    )

    req.on(
      'error'
      (e) ->
        console.log("Got error: #{e.message}")
    )

    req.end()

  _doRequest: (requestOptions, callback) ->
    req = @http.request(
      requestOptions
    )

    req.on(
      'response'
      (res) =>
        html = ''

        res.on(
          'data'
          (chunk) =>
            html += chunk
        )

        res.on(
          'end'
          =>
            callback(html)
        )
    )

    req.on(
      'error'
      (e) ->
        console.log("Got error: #{e.message}")
    )

    req.end()

  _parseAuthCode: ->
    throw 'You have to implement the logic to parse authentication data'

module.exports = BaseAdapter