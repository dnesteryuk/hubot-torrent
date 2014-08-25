sharedSet = (Parser, wrapHtml, wrapRes) ->
  describe 'when there are items on the page', ->
    beforeEach ->
      tracker = 'test'

      @items = [{
        name:             'Iron'
        torrent_file_url: 'iron url'
        size:             '10'
        seeds:            1
        tracker:          tracker
      }, {
        name:             'Mouse'
        torrent_file_url: 'mouse url'
        size:             '20'
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

module.exports = sharedSet