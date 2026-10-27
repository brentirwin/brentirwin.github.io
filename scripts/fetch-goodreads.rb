#!/usr/bin/env ruby
# Fetches your Goodreads "read" shelf RSS feed and saves it to _data/goodreads.json,
# which _includes/goodreads-shelf.html turns into the "Recently read" list.
#
# The user comes from `elsewhere.goodreads` in _config.yml (e.g. "6518326-brent-irwin").
# GitHub runs this automatically (see .github/workflows/pages.yml); to run it
# yourself:  ruby scripts/fetch-goodreads.rb

require "json"
require "net/http"
require "rexml/document"
require "time"
require "uri"
require "yaml"

# Your shelves that mean "what I thought of it", in place of star ratings.
VERDICTS = %w[loved-it liked-it not-for-me].freeze

root = File.expand_path("..", __dir__)
profile = YAML.load_file(File.join(root, "_config.yml")).dig("elsewhere", "goodreads").to_s.strip
user_id = profile[/\d+/]
abort "No Goodreads user set under elsewhere.goodreads in _config.yml" if user_id.nil?

uri = URI("https://www.goodreads.com/review/list_rss/#{user_id}?shelf=read&sort=date_read&order=d")
response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
  http.get(uri.request_uri, "User-Agent" => "Mozilla/5.0 (personal homepage bookshelf)")
end
abort "Goodreads returned HTTP #{response.code} for #{uri}" unless response.is_a?(Net::HTTPSuccess)

doc = REXML::Document.new(response.body)
books = []
doc.elements.each("rss/channel/item") do |item|
  text = ->(name) { item.elements[name]&.text.to_s.strip }
  read_at = text.call("user_read_at")
  shelves = text.call("user_shelves").split(",").map(&:strip)

  books << {
    "title"   => text.call("title"),
    "author"  => text.call("author_name").squeeze(" "),
    "read"    => read_at.empty? ? nil : Time.rfc2822(read_at).utc.strftime("%Y-%m-%d"),
    "verdict" => (shelves & VERDICTS).first,
    "url"     => text.call("link").sub(/\?.*/, ""),
    "cover"   => text.call("book_medium_image_url"),
  }
end

out = File.join(root, "_data", "goodreads.json")
File.write(out, JSON.pretty_generate("profile" => profile, "books" => books) + "\n")
puts "Saved #{books.size} books to #{out}"
