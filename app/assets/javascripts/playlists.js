/*global
  google,
  jQuery
  - globals declaration for JSLint 
 */
(function ($) {
  'use strict';
  var setUp = function () {
      if (typeof google !== 'undefined') {
        $(function () {
          //load google feeds api v.1
          google.load("feeds", "1", {
            callback: function () {
              var feedSearchValue = '';
              // read from search field on key up event
              $('#feed-search').on('keyup', function () {
                var currentValue = $(this).val();
                if (currentValue !== feedSearchValue) {
                  feedSearchValue = $.trim(currentValue);
                  if (feedSearchValue !== '') {
                    // seach google feeds, encapsulate each request 
                    google.feeds.findFeeds(feedSearchValue,  (function (searchValue) {
                      return function findfeedscallback (result) {
                        // if the user does not change the request display the results
                        if (searchValue === $('#feed-search').val()) {
                          if (!result.error) {
                            var entry,
                              i;
                            $('#feed-search-error').empty();
                            $('#feed-search-results').empty();
                            for (i = 0; i < result.entries.length; i += 1) {
                              entry = result.entries[i];
                              $('#feed-search-results').append('<li><a href="' + entry.url 
                                + '">' + entry.title + '</a><button name="add-feed">add feed</button></li>');
                            }
                            // button action to add result to params hash
                            $('#feed-search-results button[name="add-feed"]').on('click', function () {
                              var index = $('form ul li').length;
                              $(this).attr('disabled', 'disabled');
                              $('form ul').append('<li>' + $(this).siblings('a').html() 
                                + '<input id="playlist_feeds_attributes_' + index 
                                + '_feed_url" name="playlist[feeds_attributes][' 
                                + index + '][feed_url]" size="30" type="text" value="' 
                                + $(this).siblings('a').attr('href') + '"></li>');
                              $('form button[type="submit"]').show();
                            });
                          } else {
                            $('#feed-search-error').text(result.error.message);
                            $('#feed-search-results').empty();
                          }
                        }
                      };
                    }(feedSearchValue)));
                  } else {
                    $('#feed-search-results').empty();
                  }
                }
              });
            }
          });
        });
      } else {
        window.setTimeout(setUp, 100);
      }
    };
  setUp();
}(jQuery));