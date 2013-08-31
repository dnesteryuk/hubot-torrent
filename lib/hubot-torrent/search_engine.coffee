RutrackerAdapter = require('./adapters/rutracker')
PslanAdapter = require('./adapters/pslan')
EventEmitter = require('events').EventEmitter

class SearchEngine extends EventEmitter
  adapters:
    rutracker: RutrackerAdapter
    pslan:     PslanAdapter

  contructor: ->

  search: (query, torrent = 'all') ->
    @result = []
    finishedAdapters = 0

    adaptersToUse = if torrent is 'all'
      val for key, val of @adapters
    else
      unless adapter = @adapters[torrent]
        throw "No adapter #{adapter}"

      [adapter]

    for adapterProt in adaptersToUse
      tracker = new adapterProt()

      tracker.on(
        'result'
        (trackerResult) =>
          @result = @result.concat(trackerResult)

          finishedAdapters++

          if finishedAdapters is adaptersToUse.length
            this.triggerResult()
      )

      tracker.search(query)

  triggerResult: ->
    if @result.length
      this.emit('result', @result)
    else
      this.emit('no_result')


module.exports = SearchEngine