Buffer  = require('buffer').Buffer
Iconv   = require('iconv').Iconv

Parser    = require('../../../lib/hubot-torrent/adapters/pslan/parser')
sharedSet = require('./../../support/shared_tests/parser')

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

    "<table id=\"highlighted\">#{rows.join('')}</table>"

  describe '#parse', ->
    sharedSet.call(this, Parser, wrapHtml, wrapRes)

    describe 'when there are Ukranian items', ->
      beforeEach ->
        tracker = 'test'

        @items = [{
          name:             'Гра'
          torrent_file_url: 'game url'
          size:             '10'
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
