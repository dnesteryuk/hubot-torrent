# Description:
#   Client for downloading files from torrent
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot torrent download <url> - adds a new torrent to the queue
#   hubot torrent search <service> <query> - search a torrent by a given query
#
# Author:
#   dnesteryuk
Client = require('node-torrent')

module.exports = (robot) ->
  client = new Client(logLevel: 'WARN')

  robot.respond /torrent search (\w+) (.*)/i, (msg) ->
    service = msg.match[1]
    query   = msg.match[2]

    msg.reply("Searching for #{query} on #{service}")

    robot.http("http://0.0.0.0:4567/search/#{msg.match[1]}/#{msg.match[2]}")
      .get() (err, res, body) ->
        if err?
          msg.reply(err)
          return

        try
          results = JSON.parse(body)
        catch e
          robot.logger.error(e)
          robot.logger.error(body)
          return

        if results.length
          robot.lastSearchRes = results

          for item, index in results
            msg.reply("#{index + 1}: Name: #{item.name} Size: #{item.size} Seeds: #{item.seeds}")
        else
          msg.reply('Any torrent was found')

  robot.respond /torrent download (.*)/i, (msg) ->
    url = msg.match[1]

    if url.match(/^\d+$/)
      item = robot.lastSearchRes[parseInt(url) - 1]
      url = 'http://0.0.0.0:4567/torrent-file/' + new Buffer(item.url).toString('base64')
      native_url = item.url

    if robot.downloadingTorrent
      robot.downloadingTorrent.stop()
      msg.reply('The previous torrent has been stopped')

    msg.reply("Started downloading #{native_url}")

    torrent = client.addTorrent(url)

    robot.downloadingTorrent = torrent

    torrent.on(
      'complete'
      ->
        msg.reply("Download of #{url} is completed")
        delete robot.downloadingTorrent

        torrent.files.forEach (file) ->
          newPath = '/home/dnesteryuk/Download' + file.path
          fs.rename(file.path, newPath)
          file.path = newPath
    )

    torrent.on(
      'error'
      (error) ->
        msg.reply(error)
        delete robot.downloadingTorrent
    )

  robot.respond /torrent status/i, (msg) ->
    unless robot.downloadingTorrent
      msg.reply('Oh, you have not started any torrent')
      return

    if robot.downloadingTorrent.stats.downloaded and robot.downloadingTorrent.isComplete()
      msg.reply('The requested torrent is downloaded')
    else
      msg.reply("It is not downloaded. Downloaded: #{robot.downloadingTorrent.stats.downloaded / 1024 / 1024} MB")
