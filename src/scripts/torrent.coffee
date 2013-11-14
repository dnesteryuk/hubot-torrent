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
        list = ''

        for item, index in results
          list += "#{index + 1}: Name: #{item.name} Size: #{item.size} Seeds: #{item.seeds}\n"

        msg.reply(list)
    )

    torrentClient.once(
      'no_result'
      ->
        msg.reply('Sorry, but I did not find any appropriate torrents')
    )

    torrentClient.search(msg.match[2], msg.match[1])

  robot.respond /torrent download (.*)/i, (msg) ->
    url = msg.match[1]

    msg.reply('Trying to add to queue...')

    torrentClient.once(
      'torrent:added'
      ->
        msg.reply('Torrent added to queue')
    )

    torrentClient.addTorrent(url)

  robot.respond /torrent status/i, (msg) ->
    torrentClient.get (err, arg) ->
      if err
        console.error err
      else
        msg.reply('Active torrents')

        list = ''

        for torrent in arg.torrents
          unless torrent.isFinished
            list += "#{torrent.name} #{torrent.percentDone * 100}%\n"

        msg.reply(list)

  robot.respond /torrent clean/i, (msg) ->
    torrentClient.removeFinished()
    msg.reply('Removed finished torrents')
