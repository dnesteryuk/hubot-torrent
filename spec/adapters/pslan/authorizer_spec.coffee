Promise = require('promise')
nock    = require('nock')

Authorizer = require('../../../lib/hubot-torrent/adapters/pslan/authorizer')

describe 'Adapter.Pslan.Authorizer', ->
  beforeEach ->
    process.env.PSLAN_USERNAME = 'testusername'
    process.env.PSLAN_PASSWORD = 'testpassword'

    nock.disableNetConnect()

  describe 'initialize', ->
    beforeEach ->
      @errorMsg = 'To use Pslan adapter you need to define credentials to the service.' +
        " Please, add following environment variables to ~/.bashrc file\n" +
        "export PSLAN_USERNAME=\"your value\"\n" +
        "export PSLAN_PASSWORD=\"your value\""

    describe 'when there are required data', ->
      it 'does not raise any error', ->
        new Authorizer()

    describe 'when there is not username', ->
      beforeEach ->
        delete process.env['PSLAN_USERNAME']

      it 'raises an error about missed data', (done) ->
        try
          new Authorizer()
        catch e
          expect(e).toEqual(@errorMsg)
          done()

    describe 'when there is not password', ->
      beforeEach ->
        delete process.env['PSLAN_PASSWORD']

      it 'raises an error about missed data', (done) ->
        try
          new Authorizer()
        catch e
          expect(e).toEqual(@errorMsg)
          done()

  describe '#authorize', ->
    beforeEach ->
      @mock = nock(
          'http://www.pslan.com'
          {
            reqheaders:
              'Content-Type':   'application/x-www-form-urlencoded'
              'Content-Length': 43
              'User-Agent':     'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:23.0) Gecko/20100101 Firefox/23.0'
          }
        )
        .post(
          '/takelogin.php'
          {
            username: 'testusername'
            password: 'testpassword'
          }
        )

      @authorizer = new Authorizer()

    describe 'on successful authorization', ->
      beforeEach ->
        @mock.reply(
          200
          'Hello World!'
          {
            'set-cookie': [
              'advs=0; expires=Thu, 18-Sep-2014 13:47:47 GMT; path=/; domain=pslan.com; secure;',
              'advs=0; expires=Thu, 18-Sep-2014 13:47:47 GMT; path=/; domain=pslan.kiev.ua; secure',
              'uid=10; expires=Tue, 19-Jan-2038 03:14:07 GMT; path=/',
              'pass=das21das; expires=Tue, 19-Jan-2038 03:14:07 GMT; path=/'
            ]
          }
        )

      it 'stores the authorization data', (done) ->
        @authorizer.authorize(
          =>
            expect(@authorizer.authorizedData()).toEqual(
              'uid=10; pass=das21das'
            )

            done()
        )

    describe 'on failure', ->
      beforeEach ->
        @mock.reply(
          501
          'something went wrong'
        )

      xit 'throws an error', ->
        @authorizer.authorize()