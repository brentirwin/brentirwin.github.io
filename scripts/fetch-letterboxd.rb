#!/usr/bin/env ruby
# Fetches your Letterboxd RSS feed and saves the diary to _data/letterboxd.json,
# which _includes/letterboxd-diary.html turns into the "Recently watched" list.
#
# The username comes from `elsewhere.letterboxd` in _config.yml.
# GitHub runs this automatically (see .github/workflows/pages.yml); to run it
# yourself:  ruby scripts/fetch-letterboxd.rb

require "json"
require "net/http"
require "rexml/document"
require "uri"
require "yaml"

root = File.expand_path("..", __dir__)
username = YAML.load_file(File.join(root, "_config.yml")).dig("elsewhere", "letterboxd").to_s.strip
abort "No Letterboxd username set under elsewhere.letterboxd in _config.yml" if username.empty?

uri = URI("https://letterboxd.com/#{username}/rss/")
response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
  http.get(uri.request_uri, "User-Agent" => "Mozilla/5.0 (personal homepage diary)")
end
abort "Letterboxd returned HTTP #{response.code} for #{uri}" unless response.is_a?(Net::HTTPSuccess)

def stars(rating)
  return "" if rating.nil?
  ("★" * rating.floor) + (rating % 1 >= 0.5 ? "½" : "")
end

doc = REXML::Document.new(response.body)
entries = []
doc.elements.each("rss/channel/item") do |item|
  text = ->(name) { item.elements[name]&.text.to_s.strip }
  watched = text.call("letterboxd:watchedDate")
  next if watched.empty? # lists and other non-diary items have no watch date

  rating = text.call("letterboxd:memberRating")
  rating = rating.empty? ? nil : rating.to_f
  poster = text.call("description")[/<img src="([^"]+)"/, 1]

  entries << {
    "title"   => text.call("letterboxd:filmTitle"),
    "year"    => text.call("letterboxd:filmYear"),
    "watched" => watched,
    "rating"  => rating,
    "stars"   => stars(rating),
    "liked"   => text.call("letterboxd:memberLike") == "Yes",
    "rewatch" => text.call("letterboxd:rewatch") == "Yes",
    "url"     => text.call("link"),
    "poster"  => poster,
  }
end

# Newest watch date first. The feed is ordered by when you logged each film,
# so backdated entries need moving; films from the same day keep feed order.
entries = entries.each_with_index.sort_by { |e, i| [e["watched"], -i] }.reverse.map(&:first)

out = File.join(root, "_data", "letterboxd.json")
File.write(out, JSON.pretty_generate("username" => username, "entries" => entries) + "\n")
puts "Saved #{entries.size} diary entries to #{out}"
