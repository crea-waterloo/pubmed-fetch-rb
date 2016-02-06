# main.rb

require 'active_record'
require 'active_record/schema_dumper'
# require './lib/pubmed_abstract.rb'
# require './lib/pubmed_parser.rb'
require './lib/pubmed_fetcher.rb'
require './debug_constants.rb'

# ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Base.establish_connection(
  :adapter => 'postgresql',
  :database => 'crea',
  :encoding => 'utf-8',
  :host => 'localhost',
  :username => 'crea_user',
  :password => 'creapass'
)

filename = "db/schema.rb"
File.open(filename, "w:utf-8") do |file|
  ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
end

search_terms_file = "docs/terms"
File.readlines(search_terms_file).each do |line|
  fetcher = PubmedFetcher.new(line.chomp)
  fetcher.fetch
end
