Buffer  = require('buffer').Buffer
Iconv   = require('iconv').Iconv

Parser = require('../../../lib/hubot-torrent/adapters/pslan/parser')

describe 'Adapters.Pslan.Parser', ->
  wrapHtml = (body) ->
    "<html><head></head><body>#{body}</body></html>"

  wrapRes = (rows) ->
    rows = for i, row of rows
      "<tr>
        <td></td>
        <td><a href=\"#{row.torrent_file_url}\"><b>#{row.name}</b></a></td>
        <td></td>
        <td></td>
        <td>#{row.size}<br></td>
        <td><b><a><font>#{row.seeds}</font></a></b></td>
      </tr>"

    "<table id=\"highlighted\">#{rows.join('')}</table"

  describe '#parse', ->
    describe 'when there are items on the page', ->
      beforeEach ->
        tracker = 'test'

        @items = [{
          name:             'Iron'
          torrent_file_url: 'iron url'
          size:             10
          seeds:            1
          tracker:          tracker
        }, {
          name:             'Mouse'
          torrent_file_url: 'mouse url'
          size:             20
          seeds:            2
          tracker:          tracker
        }]

        html = wrapHtml(wrapRes(@items))

        @parser = new Parser(html, tracker)

      it 'returns parsed data', (done) ->
        promise = @parser.parse()

        promise.done(
          (r) =>
            expect(r).toEqual(@items)
            done()
        )

    describe 'when there are Ukranian items', ->
      beforeEach ->
        tracker = 'test'

        @items = [{
          name:             'Гра'
          torrent_file_url: 'game url'
          size:             10
          seeds:            1
          tracker:          tracker
        }]

        html = wrapHtml(wrapRes(@items))

        iconv = new Iconv('utf-8', 'windows-1251')
        html  = iconv.convert(html).toString('binary')

        @parser = new Parser(html, tracker)

      it 'returns an array with names converted to UTF8', (done) ->
        promise = @parser.parse()

        promise.done(
          (r) =>
            expect(r).toEqual(@items)
            done()
        )

    describe 'when there are not items on the page', ->
      beforeEach ->
        html = wrapHtml()

        @parser = new Parser(html, 'test')

      it 'returns an empty array', (done) ->
        promise = @parser.parse()

        promise.done(
          (r) =>
            expect(r).toEqual([])
            done()
        )

    describe 'when an error appears while parsing the page', ->
      beforeEach ->
        html = wrapHtml()

        @parser = new Parser('', 'test')

      xit 'returns error', (done) ->
        promise = @parser.parse()

        promise.done(
          (r) =>
            console.info('dsa')
            done()
        )
