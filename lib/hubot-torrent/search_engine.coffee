RutrackerAdapter = require('./adapters/rutracker')
PslanAdapter     = require('./adapters/pslan')
EventEmitter     = require('events').EventEmitter
Promise          = require('promise')

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
        throw "The adapter '#{torrent}' is not registered"

      [adapter]

    # for adapterProt in adaptersToUse
    #   tracker = new adapterProt()

    #   tracker.on(
    #     'result'
    #     (trackerResult) =>
    #       @result = @result.concat(trackerResult)

    #       finishedAdapters++

    #       if finishedAdapters is adaptersToUse.length
    #         this.triggerResult()
    #   )

    promises = for adapterProt in adaptersToUse
      tracker = new adapterProt()
      tracker.search(query)

    Promise.all(
      promises
      this._displayError
    ).done(
      this.triggerResult
    )

  triggerResult: (args...) =>
    console.info('trigger results', args)

    if @result.length
      this.emit('result', @result)
    else
      this.emit('no_result')

  _displayError: (errors) ->
    for error in errors
      console.info(error)

module.exports = SearchEngine