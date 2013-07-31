# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# polling for new tracks on fresh playlist. code analogous to:
# Ryan Bates / Railscasts - http://railscasts.com/episodes/229-polling-for-changes-revised?view=asciicast
console.log("before TrackPoller")
@TrackPoller =
  poll: ->
    setTimeout @request, 5000
    console.log("poll called")

  request: ->
    $.get($('#tracks').data('url'), after:$('.track').last().data('id'))
    console.log($('#tracks').data('url'), after:$('.track').last().data('id'))


jQuery ->
  console.log("in jquery before track poller if")
  if $('#tracks').length > 0
    console.log("inside track poller if")
    TrackPoller.poll()