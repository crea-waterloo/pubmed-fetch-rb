# lib/pubmed_parser.rb

require 'lib/pubmed_parser_helper'
require 'lib/pubmed_abstract_parser'

class PubmedParser

  attr_reader :response

  def initialize(response)
    @response = response
  end

  def parse
    normalize_response
    split_response
    @abstracts.each do |abstract| 
      abstract_parser = PubmedAbstractParser.new abstract
      abstract_parser.parse
    end
  end

  private

  def normalize_response
    @response = "\n\n" + @response
  end

  def split_response
    @abstracts = abs_1.split(/\n\n/).drop(1)
  end

  def 
end
