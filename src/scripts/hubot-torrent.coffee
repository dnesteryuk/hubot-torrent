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
#   hubot torrent search <torrent_site> <query> - search a torrent by a given query
#
# Author:
#   dnesteryuk
Client = require('node-torrent')
sys    = require('sys')
exec   = require('child_process').exec

module.exports = (robot) ->
  robot.respond /torrent search (\w+) (.*)/i, (msg) ->
    exec(
      "bundle exec ruby /home/dnesteryuk/projects/hubot-torrent/src/search_engine.rb #{msg.match[1]} #{msg.match[2]}"
      (error, stdout, stderr) ->
        msg.reply(stdout)

        results = JSON.parse(stdout)

        if error?
          msg.reply(error)

        if results.length
          robot.lastSearchRes = results

          for item, index in results
            msg.reply("#{index + 1}: Name: #{item.name} Size: #{item.size} Seeds: #{item.seeds}")
    )


  robot.respond /torrent download (.*)/i, (msg) ->
    url = msg.match[1]

    if parseInt(url) > 0
      url = robot.lastSearchRes[url - 1].url

    msg.reply("Started downloading #{url}")

    client = new Client(logLevel: 'ERROR')
    torrent = client.addTorrent(url)

    robot.downloadingTorrent = torrent

    torrent.on(
      'complete'
      ->
        msg.reply("Download of #{url} is completed")

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
      msg.reply("It is not downloaded. Downloaded: #{robot.downloadingTorrent.stats.downloaded / 1024 / 1024} MB")
