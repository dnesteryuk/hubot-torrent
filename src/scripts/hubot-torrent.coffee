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
#
# Author:
#   dnesteryuk
Client = require('node-torrent')

module.exports = (robot) ->
  robot.respond /torrent download (.*)/i, (msg) ->
    url = msg.match[1]

    msg.reply("Started downloading #{url}")

    client = new Client(logLevel: 'ERROR')
    torrent = client.addTorrent(url)

    robot.downloadingTorrent = torrent

    torrent.on(
      'complete'
      ->
        msg.send("Download of #{url} is completed")

        torrent.files.forEach (file) ->
          newPath = '/home/dnesteryuk/Download' + file.path
          fs.rename(file.path, newPath)
          file.path = newPath
    )

  robot.respond /torrent status/i, (msg) ->
    unless robot.downloadingTorrent
      msg.reply('Oh, you have not started any torrent')

    if robot.downloadingTorrent.isComplete()
      msg.reply('The requested torrent is downloaded')
    else
      msg.reply("It is not downloaded. Downloaded: #{robot.downloadingTorrent.stats.downloaded}")
