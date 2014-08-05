Transmission = require('transmission')
EventEmitter = require('events').EventEmitter
SearchEngine = require('./hubot-torrent/search_engine')

class HubotTorrent extends EventEmitter
  constructor: ->
    # TODO: find the way to configure options for
    # trasmission
    @client = new Transmission(
      host:     'localhost'
      port:     9091
      username: 'transmission'
      password: 'transmission'
    )

    @searchEngine = new SearchEngine()

    @searchEngine.on(
      'result'
      (result) =>
        @_lastResult = result
        this.emit('result', result)

        this._removeListenersForSearch()
    )

    @searchEngine.on(
      'no_result'
      =>
        this.emit('no_result')

        this._removeListenersForSearch()
    )

  search: (args...) ->
    @searchEngine.search.apply(@searchEngine, args)

  fullInfo: (index) ->
    if index.match(/^\d+$/)
      unless @_lastResult
        throw 'No search results'

      @_lastResult[parseInt(index) - 1]

  activeTorrents: (err, arg) ->
    @client.get(err, arg)

  addTorrent: (index) ->
    unless process.env.HUBOT_DOWNLOAD_DIR
      throw "Please, specify a download directory in ~/.bashrc file\n" +
        'export HUBOT_DOWNLOAD_DIR="yourpath"'

    if index.match(/^\d+$/)
      unless @_lastResult
        throw 'No search results'

      item = @_lastResult[parseInt(index) - 1] # TODO: it should be moved to search engine
      url  = item.torrent_file_url

      tracker = item.tracker

      tracker.once(
        'torrent:file'
        (fileName) =>
          @client.add(
            fileName
            'download-dir': process.env.HUBOT_DOWNLOAD_DIR
            (err, result) =>
              if err
                console.info(err)
              else
                this.emit('torrent:added')
          )
      )

      tracker.downloadTorrentFile(url)
    else
      throw 'Number of torrent should be passed'

  removeFinishedTorrents: ->
    @client.get (err, arg) =>
      for torrent in arg.torrents
        if torrent.isFinished
          @client.remove(
            [torrent.id]
            ->
          )

  _removeListenersForSearch: ->
    this.removeAllListeners('result')
    this.removeAllListeners('no_result')

module.exports = HubotTorrent