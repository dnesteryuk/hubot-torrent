EventEmitter = require('events').EventEmitter
Promise      = require('promise')

class BaseAdapter extends EventEmitter
  userAgent: 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:23.0) Gecko/20100101 Firefox/23.0'

  constructor: ->
    @http        = require('http')
    @querystring = require('querystring')

  search: (query) ->
    @query = query

    new Promise(
      this.login
      this._displayError
    ).then(
      this.doSearch
    ).then(
      this.parseResp
    )

  login: (resolve, reject) =>
    req = @http.request(
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
        console.log("Got error: #{e.message}")
        reject()
    )

    req.write(this._loginData())

    req.end()

  doSearch: (resolve) =>
    new Promise(
      (resolve) =>
        this._doRequest(
          this._searchOptions()
          resolve
        )
      this._displayError
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

  _doRequest: (requestOptions, resolve) ->
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
            console.info('got html')
            resolve(html)
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

  _displayError: (errors) ->
    for error in errors
      console.info(error)

module.exports = BaseAdapter