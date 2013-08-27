RutrackerAdapter = require('./adapters/rutracker')
EventEmitter = require('events').EventEmitter

class SearchEngine
  adapters =
    rutracker: RutrackerAdapter

  contructor: ->
    __extend(this, EventEmitter)

  search: (query, torrent = 'all') ->
    results = []

    adaptersToUse = if torrent is 'all'
      val for key, val in @adapters
    else
      unless adapter = @adapters[torrent]
        throw "No adapter #{adapter}"

      [adapter]

    for adapterProt in adaptersToUse
      adapter = new adapterProt(query)

      adapter.on(
        'result'
        (trackerRes) ->
          results.conctat(trackerRes)
      )

      adapter.search()

exports.searchEngine = SearchEngine