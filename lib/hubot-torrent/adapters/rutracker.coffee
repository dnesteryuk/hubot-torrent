EventEmitter = require('events').EventEmitter
http = require('http')
querystring = require('querystring')

class RutrackerAdapter extends EventEmitter
  trackerHost: 'rutracker.org'
  pathToLogin: '/forum/login.php'

  constructor: (query) ->
    @query = query

  search: ->
    this.login()

  login: ->
    data = querystring.stringify(
      login_username: 'nest_d'
      login_password: 'e5kad'
      redirect:       'index.php'
      login:          'Вход'
    )

    options =
      host:   "login.#{@trackerHost}"
      port:   80
      method: 'POST'
      path:   '/forum/login.php'
      headers:
        'Content-Type':   'application/x-www-form-urlencoded'
        'Content-Length': data.length
        'Referer':       "http://login.#{@trackerHost}#{@pathToLogin}"
        'User-Agent':    'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:23.0) Gecko/20100101 Firefox/23.0'

    req = http.request(
      options
      (res) =>
        @authCode = res.headers['set-cookie'][0].match(/bb_data=([\w-\d]+);/)[0].replace(';', '')

        this.doSearch()
    )

    req.on(
      'error'
      (e) ->
        console.log("Got error: #{e.message}")
    )

    req.write(data)

    req.end()

  doSearch: ->
    options =
      host:   @trackerHost
      port:   80
      method: 'GET'
      path:   "/forum/tracker.php?nm=#{@query}"
      headers:
        'Cookie':     @authCode
        'User-Agent': 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:23.0) Gecko/20100101 Firefox/23.0'

    req = http.request(
      options
    )

    req.on(
      'response'
      (res) =>
        html = ''

        res.on(
          'data'
          (chunk) =>
            html += chunk
        )

        res.on(
          'end'
          =>
            this.parseResp(html)
        )
    )

    req.on(
      'error'
      (e) ->
        console.log("Got error: #{e.message}")
    )

    req.end()

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
          console.info(rows.length)

          window.$.each(
            rows
            (index, row) =>
              cells = window.$(row).find('td')
              a     = cells.eq(3).find('a')

              data.push(
                name:             a.text()
                torrent_file_url: "http://dl.rutracker.org/forum/dl.php?t=#{a.data('topic_id')}"
                size:             cells.eq(5).children('a').text().replace(/[^\w\d\s]+/g, '')
                seeds:            cells.eq(6).text()
              )
          )

          this.emit('result', data)
    )


module.exports = RutrackerAdapter