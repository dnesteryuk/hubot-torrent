Promise = require('promise')
fs      = require('fs')

class Parser
  constructor: (@_html, @_tracker) ->
    @_jquery  = fs.readFileSync("#{__dirname}/../../../../src/jquery.js", 'utf-8')

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
    new Extractor(window, tracker: @_tracker).extract()

module.exports = Parser