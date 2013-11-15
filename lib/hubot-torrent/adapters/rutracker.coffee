BaseAdapter = require('./base')

class RutrackerAdapter extends BaseAdapter
  trackerHost: 'rutracker.org'
  pathToLogin: '/forum/login.php'

  parseResp: (html) ->
    data = []

    jsdom = require('jsdom')

    jsdom.env(
      html
      ['http://code.jquery.com/jquery.js']
      (errors, window) =>
        if errors
          console.error(errors)
        else
          rows = window.$('.forumline.tablesorter tbody tr.hl-tr')

          window.$.each(
            rows
            (index, row) =>
              cells = window.$(row).find('td')
              a     = cells.eq(3).find('a')

              data.push(
                name:             a.text()
                torrent_file_url: a.data('topic_id')
                size:             cells.eq(5).children('a').text().replace(/[^\w\d\s\.]+/g, '')
                seeds:            cells.eq(6).text()
                tracker:          this
              )
          )

          this.emit('result', data)
    )

  downloadTorrentFile: (id) ->
    options =
      host:   'dl.rutracker.org'
      port:   80
      method: 'POST'
      path:   "/forum/dl.php?t=#{id}"
      headers:
        'Accept-Encoding': 'gzip,deflate,sdch'
        'Content-Type':    'application/x-www-form-urlencoded'
        'Content-Length':  0
        'Cookie':          "#{@authCode}; bb_dl=#{id}"
        'User-Agent':      @userAgent

    super options

  _parseAuthCode: (res) ->
    @authCode = res.headers['set-cookie'][0].match(/bb_data=([\w-\d]+);/)[0].replace(';', '')

  _loginData: ->
    @querystring.stringify(
      login_username: process.env.RUTRACKER_LOGIN
      login_password: process.env.RUTRACKER_PASSWORD
      redirect:       'index.php'
      login:          'Вход'
    )

  _loginOptions: ->
    host:   "login.#{@trackerHost}"
    port:   80
    method: 'POST'
    path:   '/forum/login.php'
    headers:
      'Content-Type':   'application/x-www-form-urlencoded'
      'Content-Length': @_loginData.length
      'Referer':        "http://login.#{@trackerHost}#{@pathToLogin}"
      'User-Agent':     @userAgent

  _searchOptions: ->
    host:   @trackerHost
    port:   80
    method: 'GET'
    path:   "/forum/tracker.php?nm=#{@query}"
    headers:
      'Cookie':     @authCode
      'User-Agent': @userAgent

module.exports = RutrackerAdapter