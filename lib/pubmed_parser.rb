# lib/pubmed_parser.rb

require './lib/pubmed_parser_helper'
require './lib/pubmed_abstract_parser'

class PubmedParser

  def initialize(response, search_term)
    @response = response
    @search_term = search_term
  end

  def parse
    unless returned_error?
      normalize_response
      split_response
      @abstracts.each do |abstract| 
        abstract_parser = PubmedAbstractParser.new abstract, @search_term
        abstract_parser.parse
        abstract_parser.store
      end
    end
  end

  private

  def returned_error?
    error = @response.match(/<eFetchResult>\s*<ERROR>.+<\/ERROR>\s*<\/eFetchResult>/)
    puts 'Fetch returned error!' if error
    error
  end

  def normalize_response
    @response = "\n\n" + @response
  end

  def split_response
    @abstracts = @response.split(/\n\n\n\d+\./).drop(1)
  end
end
