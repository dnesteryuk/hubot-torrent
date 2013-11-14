Transmission = require('transmission')
EventEmitter = require('events').EventEmitter
SearchEngine = require('./hubot-torrent/search_engine')

class HubotTorrent extends EventEmitter
  constructor: ->
    @client = new Transmission(
      host: 'localhost'
      port: 9091
      username: 'transmission'
      password: 'transmission'
    )

    @searchEngine = new SearchEngine()

    @searchEngine.on(
      'result'
      (result) =>
        @_lastResult = result
        this.emit('result', result)

        this.removeAllListeners('result')
        this.removeAllListeners('no_result')
    )

    @searchEngine.on(
      'no_result'
      =>
        this.emit('no_result')

        this.removeAllListeners('result')
        this.removeAllListeners('no_result')
    )

  search: (args...) ->
    @searchEngine.search.apply(@searchEngine, args)

  get: (err, arg) ->
    @client.get(err, arg)

  addTorrent: (url) ->
    if url.match(/^\d+$/)
      item = @_lastResult[parseInt(url) - 1] # TODO: it should be moved to search engine
      url  = item.torrent_file_url

      tracker = item.tracker

      tracker.once(
        'torrent:file'
        (fileName) =>
          @client.add(
            fileName
            'download-dir': '/tmp'
            (err, result) =>
              if err
                console.info(err)
              else
                this.emit('torrent:added')
          )
      )

      tracker.downloadTorrentFile(url)

  removeFinished: ->
    @client.get (err, arg) ->
      for torrent in arg.torrents
        torrent.remove([torrent.id])

module.exports = HubotTorrent