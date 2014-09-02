class SearchResults
  _maxNameLength: 50

  constructor: (@_printer) ->

  respond: (results) ->
    list = for item, index in results
      this._formatItem(item, index)

    @_printer.reply(list.join("\n"))

  _formatItem: (item, index) ->
    name = if item.name.length > @_maxNameLength
      item.name[0...@_maxNameLength] + '...'
    else
      item.name

    "#{index + 1}: Name: #{name} Size: #{item.size} Seeds: #{item.seeds}"

module.exports = SearchResults