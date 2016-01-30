# main.rb

require 'active_record'
require 'active_record/schema_dumper'
require './lib/pubmed_abstract.rb'

ActiveRecord::Base.logger = Logger.new(STDOUT)

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

new_abs = PubmedAbstract.new({pmid: 1, title: "hello world", authors: "these cool ppl", section_name: "OBJECT", section_body: "To see the world and more of the world"})
new_abs.save
