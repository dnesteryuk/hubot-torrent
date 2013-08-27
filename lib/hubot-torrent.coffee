Client       = require('node-torrent')
SearchEngine = require('./hubot-torrent/search_engine')
EventEmitter = require('events').EventEmitter

class HubotTorrent
  constructor: ->
    __extend(this, EventEmitter)

    @client       = new Client()
    @searchEngine = new SearchEngine()

    @searchEngine.on(
      'result'
      (result) =>
        this.trigger('result', result)
    )

  search: (args...) ->
    @searchEngine.search.call(@searchEngine, args)

  addTorrent: (url) ->
    @client.addTorrent(url)

exports.hubotTorrent = HubotTorrent
