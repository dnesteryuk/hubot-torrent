Promise = require('promise')
nock    = require('nock')

AuthorizeGranter = require('../../../lib/hubot-torrent/adapters/pslan/authorize_granter')

describe 'Adapter.Pslan.AuthorizeGranter', ->
  beforeEach ->
    process.env.PSLAN_USERNAME = 'testusername'
    process.env.PSLAN_PASSWORD = 'testpassword'

  describe '#parseAuthCode', ->
    beforeEach ->
      @resp =
        headers:
          {
            'set-cookie': [
              'advs=0; expires=Thu, 18-Sep-2014 13:47:47 GMT; path=/; domain=pslan.com; secure;',
              'advs=0; expires=Thu, 18-Sep-2014 13:47:47 GMT; path=/; domain=pslan.kiev.ua; secure',
              'uid=10; expires=Tue, 19-Jan-2038 03:14:07 GMT; path=/',
              'pass=das21das; expires=Tue, 19-Jan-2038 03:14:07 GMT; path=/'
            ]
          }

      @granter = new AuthorizeGranter()

    it 'returns authorization data', ->
      expect(@granter.parseAuthCode(@resp)).toEqual(
        'uid=10; pass=das21das'
      )

  describe '#authorizeData', ->
    beforeEach ->
      @granter = new AuthorizeGranter()

    it 'returns the prepared pslan username and password', ->
      expect(@granter.authorizeData()).toEqual(
        'username=testusername&password=testpassword'
      )

    describe 'when sensitive data are present', ->
      beforeEach ->
        process.env.PSLAN_USERNAME = 'test username'
        process.env.PSLAN_PASSWORD = 'test password'

      it 'returns the prepared pslan username and password with properly handled sensitive data', ->
        expect(@granter.authorizeData()).toEqual(
          'username=test%20username&password=test%20password'
        )

  describe '#authorizeOptions', ->
    beforeEach ->
      @granter = new AuthorizeGranter()

      spyOn(@granter, 'authorizeData').andReturn('test')

    it 'returns options for HTTP request', ->
      expect(@granter.authorizeOptions()).toEqual(
        host:   'www.pslan.com'
        port:   80
        method: 'POST'
        path:   '/takelogin.php'
        headers:
          'Content-Type':   'application/x-www-form-urlencoded'
          'Content-Length': 4
      )