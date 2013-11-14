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
#   hubot torrent status - returns info about all torrents
#   hubot torrent clean - removes all finished torrents
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
          list += "#{index + 1}: Name: #{item.name[0..50]}... Size: #{item.size} Seeds: #{item.seeds}\n"

        msg.reply(list)

        info = "To download a desired torrent, please, use \n" +
          "\ttorrent download <number>\n" +
          "where 'number' is a number from the list"

        msg.reply(info)
    )

    torrentClient.once(
      'no_result'
      ->
        msg.reply('Sorry, but I did not find any appropriate torrents')
    )

    try
      torrentClient.search(msg.match[2], msg.match[1])
    catch error
      msg.reply(error)

  robot.respond /torrent download (.*)/i, (msg) ->
    index = msg.match[1]

    msg.reply('Trying to add to queue...')

    torrentClient.once(
      'torrent:added'
      ->
        msg.reply('Torrent is added to queue')
    )

    try
      torrentClient.addTorrent(index)
    catch error
      msg.reply(error)

  robot.respond /torrent info (.*)/i, (msg) ->
    index = msg.match[1]

    try
      info = torrentClient.fullInfo(index)

      list = "\nName: #{info.name}\n" +
        "Size: #{info.size}\n" +
        "Seeds: #{info.seeds}\n"

      msg.reply(list)

    catch error
      msg.reply(error)

  robot.respond /torrent status/i, (msg) ->
    torrentClient.activeTorrents (err, arg) ->
      if err
        console.error err
      else
        list = "Active torrents:\n"

        for torrent, index in arg.torrents
          list += "#{torrent.id}: #{torrent.name} #{torrent.status} #{torrent.percentDone * 100}%\n"

        msg.reply(list)

  robot.respond /torrent clean/i, (msg) ->
    torrentClient.removeFinishedTorrents()
    msg.reply('Removed all finished torrents')
