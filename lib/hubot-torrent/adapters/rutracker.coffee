EventEmitter = require('events').EventEmitter
jsdom = require('jsdom')

class RutrackerAdapter
  trackerUrl: 'http://rutracker.org/'

  contructor: (query) ->
    __extend(this, EventEmitter)

    @query = @query

  search: ->
    jsdom.env(
      @trackerUrl,
      ['http://code.jquery.com/jquery.js'],
      (errors, window) ->
        window.$('input[name="login_username"]').val('nest_d')
        window.$('input[name="login_password"]').val('')
        window.$('input[name="login"]').click()

        throw window.$('#search-text').length
    )
