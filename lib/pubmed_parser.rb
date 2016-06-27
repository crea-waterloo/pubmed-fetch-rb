# lib/pubmed_parser.rb

require './vendor/logging'
require './lib/pubmed_parser_helper'
require './lib/pubmed_abstract_parser'
require './lib/pubmed_abstract.rb'

class PubmedParser

  include Logging

  def initialize(response, search_term, options)
    @response = response.force_encoding('UTF-8')
    @search_term = search_term
    @options = options
  end

  def parse
    unless returned_error?
      normalize_response
      split_response

      success = 0

      if @options[:db]
        PubmedAbstract.transaction do
          @abstracts.each do |abstract|
            abstract_parser = PubmedAbstractParser.new(abstract, @search_term, @options)
            abstract_parser.parse
            abstract_parser.store_db && success += 1
          end
        end
      elsif @options[:stdout]
        @abstracts.each do |abstract|
          abstract_parser = PubmedAbstractParser.new(abstract, @search_term, @options)
          abstract_parser.parse
          abstract_parser.store_stdout && success += 1
        end
      end
      
      success
    end
  end

  private

  def returned_error?
    error = @response.match(/<eFetchResult>\s*<ERROR>(.+)<\/ERROR>\s*<\/eFetchResult>/)
    logger.error('Pubmed Parser') { "Fetch returned error!\n" + error[1] } if error
    error
  end

  def normalize_response
    @response = "\n\n" + @response
  end

  def split_response
    @abstracts = @response.split(/\n\n\n\d+\./).drop(1)
  end
end
