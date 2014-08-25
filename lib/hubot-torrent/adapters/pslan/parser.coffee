Buffer  = require('buffer').Buffer
Iconv   = require('iconv').Iconv
_       = require('underscore')
BaseParser = require('../base/parser')

class Parser extends BaseParser
  constructor: ->
    super

    iconv  = new Iconv('windows-1251', 'utf-8')
    @_html = iconv.convert(
      new Buffer(@_html, 'binary')
    ).toString()

  extractItems: (window) ->
    new Extractor(window, tracker: @_tracker).extract()

class Extractor
  constructor: (@_window, @_additional) ->
    @_table = @_window.$('#highlighted')

  extract: ->
    data = []

    if @_table.length
      rows = @_table.find('tr')

      @_window.$.each(
        rows
        (index, row) =>
          item = this.extractItem(row)
          data.push(item)
      )

    data

  extractItem: (row) ->
    cells    = @_window.$(row).find('td')
    nameCell = cells.eq(1)

    pathToDetails = nameCell.find('a').attr('href')

    seedsLeeches = cells.eq(5).find('b')

    _.extend({
      name:             nameCell.find('a b').text()
      torrent_file_url: pathToDetails
      size:             parseInt(cells.eq(4).text().replace('<br>', ''))
      seeds:            parseInt(seedsLeeches.eq(0).find('a font').text())
    }, @_additional)

module.exports = Parser