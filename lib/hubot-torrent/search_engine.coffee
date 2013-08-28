RutrackerAdapter = require('./adapters/rutracker')
EventEmitter = require('events').EventEmitter

class SearchEngine extends EventEmitter
  adapters:
    rutracker: RutrackerAdapter

  contructor: ->

  search: (query, torrent = 'all') ->
    results = []

    adaptersToUse = if torrent is 'all'
      val for key, val of @adapters
    else
      unless adapter = @adapters[torrent]
        throw "No adapter #{adapter}"

      [adapter]

    for adapterProt in adaptersToUse
      tracker = new adapterProt(query)

      tracker.on(
        'result'
        (trackerRes) ->
          results.conctat(trackerRes)
      )

      tracker.search()

module.exports = SearchEngine