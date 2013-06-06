#polling for new tracks on fresh playlist
@TrackPoller =
  poll: ->
    setTimeout @request, 3000

  request: ->
    $.get($('#tracks').data('url'))

jQuery ->
  if $('#tracks').length > 0
    TrackPoller.poll()

#implements the rss feed search and pick 
#global: google, jQuery
 
(($) ->
  "use strict"
  setUp = ->
    if typeof google isnt "undefined"
      $ ->
        google.load "feeds", "1",
          callback: ->
            feedSearchValue = ""
            $("#feed-search").on "keyup", ->
              currentValue = $(this).val()
              if currentValue isnt feedSearchValue
                feedSearchValue = $.trim(currentValue)
                if feedSearchValue isnt ""
                  google.feeds.findFeeds feedSearchValue, ((searchValue) ->
                    (result) ->
                      if searchValue is $("#feed-search").val()
                        unless result.error
                          entry = undefined
                          i = undefined
                          $("#feed-search-error").empty()
                          $("#feed-search-results").empty()
                          i = 0
                          while i < result.entries.length
                            entry = result.entries[i]
                            $("#feed-search-results").append "<li><a href=\"" + entry.url + "\">" + entry.title + "</a><button name=\"add-feed\">add feed</button></li>"
                            i += 1
                          $("#feed-search-results button[name=\"add-feed\"]").on "click", ->
                            index = $("form ul li").length
                            $(this).attr "disabled", "disabled"
                            $("form ul").append "<li>" + $(this).siblings("a").html() + "<input id=\"playlist_feeds_attributes_" + index + "_feed_url\" name=\"playlist[feeds_attributes][" + index + "][feed_url]\" size=\"30\" type=\"text\" value=\"" + $(this).siblings("a").attr("href") + "\"></li>"
                            $("form button[type=\"submit\"]").show()

                        else
                          $("#feed-search-error").text result.error.message
                          $("#feed-search-results").empty()
                  (feedSearchValue))
                else
                  $("#feed-search-results").empty()
    else
      window.setTimeout setUp, 100
  setUp()
) jQuery