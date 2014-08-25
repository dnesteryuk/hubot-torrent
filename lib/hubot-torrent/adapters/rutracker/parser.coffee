_          = require('underscore')
BaseParser = require('../base/parser')

class Parser extends BaseParser
  extractItems: (window) ->
    new Extractor(window, tracker: @_tracker).extract()

class Extractor
  constructor: (@_window, @_additional) ->
    @_table = @_window.$('.forumline.tablesorter')

  extract: ->
    data = []

    if @_table.length
      rows = @_table.find('tbody tr.hl-tr')

      @_window.$.each(
        rows
        (index, row) =>
          item = this.extractItem(row)
          data.push(item)
      )

    data

  extractItem: (row) ->
    cells = @_window.$(row).find('td')
    a     = cells.eq(3).find('a')

    _.extend({
      name:             a.text()
      torrent_file_url: a.data('topic_id')
      size:             cells.eq(5).children('a').text().replace(/[^\w\d\s\.]+/g, '')
      seeds:            parseInt(cells.eq(6).text())
    }, @_additional)

module.exports = Parser