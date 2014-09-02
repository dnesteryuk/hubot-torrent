sharedSet = require('./../../support/shared_tests/parser')
Parser    = require('../../../lib/hubot-torrent/adapters/rutracker/parser')

describe 'Adapters.Rutracker.Parser', ->
  wrapHtml = (body) ->
    "<html><head></head><body>#{body}</body></html>"

  wrapRes = (rows) ->
    rows = for i, row of rows
      "<tr class=\"hl-tr\">
        <td></td>
        <td></td>
        <td></td>
        <td><a data-topic_id=\"#{row.torrent_file_url}\"><b>#{row.name}</b></a></td>
        <td></td>
        <td><a>#{row.size}</a></td>
        <td>#{row.seeds}</td>
      </tr>"

    "<table class=\"forumline tablesorter\"><tbody>#{rows.join('')}</tbody></table>"

  describe '#parse', ->
    sharedSet.call(this, Parser, wrapHtml, wrapRes)