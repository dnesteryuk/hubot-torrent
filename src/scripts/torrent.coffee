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
HubotTorrent = require('hubot-torrent')

module.exports = (robot) ->
  torrentClient = new HubotTorrent()

  robot.respond /torrent search (\w+) (.*)/i, (msg) ->
    service = msg.match[1]
    query   = msg.match[2]

    msg.reply("Searching for #{query} on #{service}")

    torrentClient.once(
      'result'
      (results) ->
        for item, index in results
          msg.reply("#{index + 1}: Name: #{item.name} Size: #{item.size} Seeds: #{item.seeds}")
    )

    torrentClient.once(
      'no_result'
      ->
        msg.reply('Sorry, but I did not find any appropriate torrents')
    )

    torrentClient.search(msg.match[2], msg.match[1])

  robot.respond /torrent download (.*)/i, (msg) ->
    url = msg.match[1]

    if robot.downloadingTorrent
      robot.downloadingTorrent.stop()
      msg.reply('The previous torrent has been stopped')

    msg.reply("Started downloading")

    torrentClient.addTorrent(url)

    #robot.downloadingTorrent = torrent

    # torrent.on(
    #   'complete'
    #   ->
    #     msg.reply("Download of #{url} is completed")
    #     delete robot.downloadingTorrent

    #     torrent.files.forEach (file) ->
    #       newPath = '/home/dnesteryuk/Download' + file.path
    #       fs.rename(file.path, newPath)
    #       file.path = newPath
    # )

    # torrent.on(
    #   'error'
    #   (error) ->
    #     msg.reply(error)
    #     delete robot.downloadingTorrent
    # )

  robot.respond /torrent status/i, (msg) ->
    unless robot.downloadingTorrent
      msg.reply('Oh, you have not started any torrent')
      return

    if robot.downloadingTorrent.stats.downloaded and robot.downloadingTorrent.isComplete()
      msg.reply('The requested torrent is downloaded')
    else
      msg.reply("It is not downloaded. Downloaded: #{robot.downloadingTorrent.stats.downloaded / 1024 / 1024} MB")
