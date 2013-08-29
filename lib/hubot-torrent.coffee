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
        this.emit('result', result)
    )

    @searchEngine.on(
      'no_result'
      =>
        this.emit('no_result')
    )

  search: (args...) ->
    @searchEngine.search.apply(@searchEngine, args)

  addTorrent: (url) ->
    @client.addTorrent(url)

module.exports = HubotTorrent