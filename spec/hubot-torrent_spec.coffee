HubotTorrent = require('../lib/hubot-torrent')

describe 'HubotTorrent', ->
  beforeEach ->
    global.Transmission = jasmine.createSpy('transmission prototype')

    @transmission = jasmine.createSpyObj(
      'transmission', ['get']
    )

    global.Transmission.andReturn(@transmission)

  describe 'initialize', ->
    it 'initializes the transmission client', ->
      new HubotTorrent()

      expect(Transmission).toHaveBeenCalled()