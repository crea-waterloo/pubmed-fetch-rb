# lib/pubmed_parser.rb

require './lib/pubmed_parser_helper'
require './lib/pubmed_abstract_parser'

class PubmedParser

  def initialize(response)
    @response = response
  end

  def parse
    normalize_response
    split_response
    @abstracts.each do |abstract| 
      abstract_parser = PubmedAbstractParser.new abstract
      abstract_parser.parse
      abstract_parser.store
    end
  end

  private

  def normalize_response
    @response = "\n\n" + @response
  end

  def split_response
    @abstracts = @response.split(/\n\n\n\d+\./).drop(1)
  end
end
