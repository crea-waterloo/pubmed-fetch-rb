# main.single_stream.stdout.rb

require 'active_record'
require './lib/pubmed_fetcher.rb'

search_terms_file = "docs/terms"

File.readlines(search_terms_file).each do |line|
  PubmedFetcher.new(line.chomp, {db: false, stdout: true, stdout_split: false}).fetch
end
