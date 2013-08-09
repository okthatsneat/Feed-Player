#!/usr/bin/env ruby

REGEXP_POST = /PostWorker.*done:(.*)sec/
REGEXP_SUCCESS_EMBEDS = /extract_tracks_from_embeds success/
REGEXP_SUCCESS_COVERART = /create_tracks_for_coverart success/
REGEXP_SUCCESS_DISCOGS = /validate_and_create_tracks_semantically success/
sum = 0.0
post_count = 0.0
success_count = 0.0
File.foreach(ARGV[0]) do |line|
  if (line =~ REGEXP_POST)    
    value = line.match(REGEXP_POST).captures[0]
    sum += value.to_f
    post_count +=1
  end
  if (line =~ REGEXP_SUCCESS_EMBEDS || line =~ REGEXP_SUCCESS_DISCOGS || line =~ REGEXP_SUCCESS_COVERART)
    success_count +=1
  end

end
puts "Speed: average processing time is %.2f seconds (= %.2f minutes)"% [sum/post_count,(sum/post_count)/60] 
puts "Success Rate: %.0f posts of %.0f success, success rate is %.0f %" % [success_count,post_count,(success_count/post_count) *100]
