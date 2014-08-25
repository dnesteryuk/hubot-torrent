Promise = require('promise')
fs      = require('fs')

Buffer  = require('buffer').Buffer
Iconv   = require('iconv').Iconv

class Parser
  constructor: (@_html, @_tracker) ->
    @_jquery  = fs.readFileSync("#{__dirname}/../../../../src/jquery.js", 'utf-8')

    iconv   = new Iconv('windows-1251', 'utf-8')
    @_html  = iconv.convert(
      new Buffer(@_html, 'binary')
    ).toString()

    @_jsdom = require('jsdom')

  parse: ->
    new Promise(
      (resolve) =>
        @_jsdom.env(
          html: @_html
          src:  [@_jquery]
          done: (errors, window) =>
            if errors
              console.error(errors)
            else
              data = this.extractItems(window)
              resolve(data)
        )
    )

  extractItems: (window) ->
    data = []

    col = window.$('#highlighted')

    if col.length
      rows = col.find('tr')

      window.$.each(
        rows
        (index, row) =>
          item = this._extractItem(row, window)
          data.push(item)
      )

    data

  _extractItem: (row, window) ->
    cells    = window.$(row).find('td')
    nameCell = cells.eq(1)

    pathToDetails = nameCell.find('a').attr('href')

    seedsLeeches = cells.eq(5).find('b')

    {
      name:             nameCell.find('a b').text()
      torrent_file_url: pathToDetails
      size:             parseInt(cells.eq(4).text().replace('<br>', ''))
      seeds:            parseInt(seedsLeeches.eq(0).find('a font').text())
      tracker:          @_tracker
    }

module.exports = Parser