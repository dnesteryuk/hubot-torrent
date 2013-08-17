require 'torrent_api'
require 'open-uri'
require 'json'

torrent_api = TorrentApi.new(:pirate_bay, ARGV[0])
torrents = torrent_api.results

if torrents.size > 0
  res = torrents.map do |torrent|
    {
      name:   torrent.name,
      seeds:  torrent.seeds,
      url:    URI::encode(torrent.link),
      size:   "#{((torrent.size / 1024 / 1024) / 100).ceil * 100} MB"
    }
  end

  puts res.to_json
else
  puts [].to_json
end