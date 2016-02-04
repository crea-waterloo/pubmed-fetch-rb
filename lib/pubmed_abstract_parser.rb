# lib/pubmed_abstract_parser.rb

require './lib/pubmed_abstract.rb'

class PubmedAbstractParser

  def initialize(abstract, search_term)
    @abstract = abstract
    @search_term = search_term
  end

  def parse
    tokenize_abstract
    sanitize_tokens
    parse_pmid
    parse_title
    parse_authors
    tokenize_body
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
        end
      end
    else
      puts "--- STORE:MISSING ---"
      self.debug
    end
  end

  def debug
    puts "---------------------"
    puts "pmid: #{@pmid}"
    puts "title: #{@title}"
    puts "authors: #{@authors}"
    puts "body: #{@body || @body_parts}"
    puts "---------------------"
  end

  private

  def tokenize_abstract
    @tokens = @abstract.split(/\n\n/)
  end

  def sanitize_tokens
    @tokens.select! do |token|
      token.match(/Author information|copyright|Copyright|©/).nil?
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
    body = @tokens[-2].flatten
    body_parts = body.split(/([A-Z]+): /)
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
