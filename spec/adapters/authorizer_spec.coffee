nock = require('nock')

Authorizer = require('../../lib/hubot-torrent/adapters/authorizer')

describe 'Adapter.Authorizer', ->
  beforeEach ->
    @granter =
      name: ->
        'TestTorrent'
      requiredEnvVars: ->
        ['TEST_USERNAME', 'TEST_PASSWORD']

      authorizeOptions: ->
        host:   'google.com'
        port:   80
        method: 'POST'
        path:   '/login'
        headers:
          'Content-Type': 'application/x-www-form-urlencoded'

      authorizeData: ->
        'test=1'

      parseAuthCode: ->

    spyOn(@granter, 'parseAuthCode').andReturn('some code')

    process.env.TEST_USERNAME = 'testusername'
    process.env.TEST_PASSWORD = 'testpassword'

    nock.disableNetConnect()

  describe 'initialize', ->
    beforeEach ->
      @errorMsg = 'To use TestTorrent adapter you need to define credentials to the service.' +
        " Please, add following environment variables to ~/.bashrc file\n" +
        "export TEST_USERNAME=\"your value\"\n" +
        "export TEST_PASSWORD=\"your value\""

    describe 'when there are required data', ->
      it 'does not raise any error', ->
        new Authorizer(@granter)

    describe 'when there is not username', ->
      beforeEach ->
        delete process.env['TEST_USERNAME']

      it 'raises an error about missed data', (done) ->
        try
          new Authorizer(@granter)
        catch e
          expect(e).toEqual(@errorMsg)
          done()

    describe 'when there is not password', ->
      beforeEach ->
        delete process.env['TEST_PASSWORD']

      it 'raises an error about missed data', (done) ->
        try
          new Authorizer(@granter)
        catch e
          expect(e).toEqual(@errorMsg)
          done()

  describe '#authorize', ->
    beforeEach ->
      @mock = nock(
          'http://google.com'
          {
            reqheaders:
              'Content-Type': 'application/x-www-form-urlencoded'
              'User-Agent':   'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:23.0) Gecko/20100101 Firefox/23.0'
          }
        )
        .post(
          '/login'
          {test: 1}
        )

      @authorizer = new Authorizer(@granter)

    describe 'on successful authorization', ->
      beforeEach ->
        @mock.reply(
          201
          'Hello World!'
        )

      it 'sends the response to the authorize granter', (done) ->
        @authorizer.authorize(
          =>
            args = @granter.parseAuthCode.calls[0].args[0]
            expect(args.statusCode).toEqual(201)

            done()
        )

      it 'stores the authorization data', (done) ->
        @authorizer.authorize(
          =>
            expect(@authorizer.authorizeData()).toEqual(
              'some code'
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