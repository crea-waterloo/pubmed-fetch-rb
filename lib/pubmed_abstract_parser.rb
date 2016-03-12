# lib/pubmed_abstract_parser.rb

require './vendor/logging'
require './lib/pubmed_abstract.rb'

class PubmedAbstractParser

  include Logging

  def initialize(abstract, search_term)
    @abstract = abstract
    @search_term = search_term
    @elements = {
      :pmid => true,
      :title => true,
      :authors => true,
      :author_info => false,
      :copyright => false,
      :body => false
    }
  end

  def parse
    tokenize_abstract
    sanitize_tokens
    parse_pmid if @elements[:pmid]
    parse_title if @elements[:title]
    parse_authors if @elements[:authors]
    tokenize_body if @elements[:body]
  end

  def store
    if check_fields
      if @body
        PubmedAbstract.new({
          pmid: @pmid,
          title: @title,
          authors: @authors,
          search_term: @search_term,
          section_name: "ALL",
          section_body: @body
        }).save
        @body.flatten.split('.').each do |sentence|
          puts sentence
        end

      else
        @body_parts.each do |body_part|
          PubmedAbstract.new({
            pmid: @pmid,
            title: @title,
            authors: @authors,
            search_term: @search_term,
            section_name: body_part[0],
            section_body: body_part[1]
          }).save
          body_part[1].flatten.split('.').each do |sentence|
            puts sentence
          end

        end
      end
      true
    else
      logger.debug('Pubmed Abstract Parser') { "Missing fields for article #{@pmid}" }
      false
    end
  end

  def debug
    "pmid: #{@pmid}\n" +
    "title: #{@title}\n" +
    "authors: #{@authors}\n" +
    "body: #{@body || @body_parts}"
  end

  private

  def tokenize_abstract
    @tokens = @abstract.split(/\n\n/)
    @token_size = @tokens.size
  end

  def sanitize_tokens
    @tokens.select! do |token|
      author_info_matched = token.match(/Author information/)
      copyright_matched = token.match(/copyright|Copyright|©/)
      @elements[:author_info] = true if author_info_matched
      @elements[:copyright] = true if copyright_matched
      not (author_info_matched or copyright_matched)
    end
    @token_real_size = @tokens.size
    if @token_real_size <= 4
      # logger.info('Pubmed Abstract Parser'){ "No Abstract Body" }
    else
      @elements[:body] = true
    end

  end

  def parse_pmid
    @pmid = @tokens[-1].match(/^PMID: (\d+)/)[1]
  end

  def parse_title
    @title = @tokens[1].flatten
  end

  def parse_authors
    @authors = @tokens[2].flatten
  end

  def tokenize_body
    body = @tokens[-2]
    body_parts = body.split(/\n([A-Z]+): /)
    # body_parts.each { |b| b.flatten! }
    if body_parts.length == 1
      @body = body
    else
      @body_parts = body_parts.drop(1).each_slice(2).to_a
    end
  end

  def check_fields
    @pmid and @title and @authors and (@body or @body_parts)
  end
end
