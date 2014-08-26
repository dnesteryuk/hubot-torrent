Promise = require('promise')
nock    = require('nock')

AuthorizeGranter = require('../../../lib/hubot-torrent/adapters/rutracker/authorize_granter')

describe 'Adapter.Rutracker.AuthorizeGranter', ->
  beforeEach ->
    process.env.RUTRACKER_LOGIN    = 'testusername'
    process.env.RUTRACKER_PASSWORD = 'testpassword'

  describe '#parseAuthCode', ->
    beforeEach ->
      @resp =
        headers:
          {
            'set-cookie': [
              'bb_data=1-29549482-3kUeKu97ccVkpx1fYxmz-1299800040; expires=Wed, 26-Aug-2015 19:42:50 GMT; path=/forum/; domain=.rutracker.org; httponly'
            ]
          }

      @granter = new AuthorizeGranter()

    it 'returns authorization data', ->
      expect(@granter.parseAuthCode(@resp)).toEqual(
        'bb_data=1-29549482-3kUeKu97ccVkpx1fYxmz-1299800040'
      )

  describe '#authorizeData', ->
    beforeEach ->
      @granter = new AuthorizeGranter()

    it 'returns the prepared pslan username and password', ->
      expect(@granter.authorizeData()).toEqual(
        'login_username=testusername&login_password=testpassword&redirect=index.php&login=%D0%92%D1%85%D0%BE%D0%B4'
      )

  describe '#authorizeOptions', ->
    beforeEach ->
      @granter = new AuthorizeGranter()

      spyOn(@granter, 'authorizeData').andReturn('test')

    it 'returns options for HTTP request', ->
      expect(@granter.authorizeOptions()).toEqual(
        host:   'login.rutracker.org'
        port:   80
        method: 'POST'
        path:   '/forum/login.php'
        headers:
          'Content-Type':   'application/x-www-form-urlencoded'
          'Content-Length': 4
          'Referer':        "http://login.rutracker.org/forum/login.php"
      )