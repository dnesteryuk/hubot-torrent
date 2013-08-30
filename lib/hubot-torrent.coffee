Client       = require('node-torrent')
EventEmitter = require('events').EventEmitter
SearchEngine = require('./hubot-torrent/search_engine')

class HubotTorrent extends EventEmitter
  constructor: ->
    @client       = new Client(logLevel: 'DEBUG')
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

  addTorrent: (url) ->
    if url.match(/^\d+$/)
      item = @_lastResult[parseInt(url) - 1] # TODO: it should be moved to search engine
      url  = item.torrent_file_url

      tracker = item.tracker

      tracker.once(
        'torrent:file'
        (fileName) =>
          @client.addTorrent(fileName)
      )

      tracker.downloadTorrentFile(url)

module.exports = HubotTorrent