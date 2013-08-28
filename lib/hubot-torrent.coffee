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
        this.trigger('result', result)
    )

  search: (args...) ->
    @searchEngine.search.apply(@searchEngine, args)

  addTorrent: (url) ->
    @client.addTorrent(url)

module.exports = HubotTorrent