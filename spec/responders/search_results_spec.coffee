SearchResults = require('../../lib/hubot-torrent/responders/search_results')

describe 'Responders.SearchResults', ->
  describe '#respond', ->
    beforeEach ->
      @printer = jasmine.createSpyObj('printer', ['reply'])

      @responder = new SearchResults(@printer)

    it 'replies with a list of info about torrents', ->
      results = [
        name:  'TestMovie'
        size:  '100Gb'
        seeds: 10
      ]

      @responder.respond(results)

      expect(@printer.reply).toHaveBeenCalledWith(
        "1: Name: TestMovie Size: 100Gb Seeds: 10"
      )

    describe 'when there are a few items', ->
      it 'replies with a list of info about torrents which are separated by the new line symbol', ->
        results = [
          {
            name:  'TestMovie'
            size:  '100Gb'
            seeds: 10
          }
          {
            name:  'TestMovie2'
            size:  '200Gb'
            seeds: 20
          }
        ]

        @responder.respond(results)

        expect(@printer.reply).toHaveBeenCalledWith(
          "1: Name: TestMovie Size: 100Gb Seeds: 10\n" +
          "2: Name: TestMovie2 Size: 200Gb Seeds: 20"
        )

    describe 'when there are a long name for a movie', ->
      it 'cuts long name', ->
        results = [
          name:  'TestMovieTestMovieTestMovieTestMovieTestMovietestMoview'
          size:  1
          seeds: 1
        ]

        @responder.respond(results)

        expect(@printer.reply).toHaveBeenCalledWith(
          "1: Name: TestMovieTestMovieTestMovieTestMovieTestMovietestM... Size: 1 Seeds: 1"
        )