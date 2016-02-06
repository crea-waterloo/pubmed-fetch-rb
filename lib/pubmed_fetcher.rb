# lib/pubmed_fetch.rb

require 'net/http'
require './vendor/logging'
require './lib/pubmed_parser'

class PubmedFetcher

  include Logging

  BASE_URL = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/'
  API_METHODS = {
    :esearch => 'esearch.fcgi',
    # :esummary => 'esummary.fcgi',
    :efetch => 'efetch.fcgi'
  }
  DEFAULT_OPTIONS = {
    :field => 'all',
    :mindate => 1960,
    :maxdate => Time.now.year,
    :batch_size => 100
  }

  # TODO Make documentation for options!
  def initialize(term, options = {})
    @term = term
    @options = DEFAULT_OPTIONS.merge(options)
    logger.info('Pubmed Fetcher') { "instantiated for search term: #{term}" }
  end

  def fetch
    esearch
    (1..@count).step(@options[:batch_size]) do |start_index|
      efetch(start_index)
    end
  end

  private

  def request(api_method, params)
    raise "api not implemented #{api_method}" unless API_METHODS[api_method]
    uri = URI(BASE_URL + API_METHODS[api_method])
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    res.body if res.is_a?(Net::HTTPSuccess)
  end

  def esearch
    param = {
      :db => 'pubmed',
      :term => @term,
      :field => @options[:field],
      :retstart => 0,
      :retmax => 1,
      :retmode => 'json',
      :datetype => 'mdat',
      :mindate => @options[:mindate],
      :maxdate => @options[:maxdate],
      :usehistory => 'y'
    }
    response = request(:esearch, param)
    handle_search_response(response)
  end

  def handle_search_response(response)
    response_hash = JSON.parse(response)

    esearchresult = response_hash["esearchresult"]
    @count = esearchresult["count"].to_i
    @querykey = esearchresult["querykey"]
    @webenv = esearchresult["webenv"]

    querytranslation = esearchresult["querytranslation"]
    logger.debug('Pubmed Fetcher Translation') { querytranslation }
  end

  def efetch(start_index)
    logger.info("Pubmed Fetcher: #{@term}") { "Fetching abstracts... #{start_index} / #{@count}" }

    param = {
      :db => 'pubmed',
      :retstart => start_index,
      :retmax => @options[:batch_size],
      :rettype => 'abstract',
      :retmode => 'text',
      :query_key => @querykey,
      :webenv => @webenv
    }
    response = request(:efetch, param)
    pubmed_parser = PubmedParser.new(response, @term)
    success = pubmed_parser.parse

    logger.info("Pubmed Fetcher: #{@term}") { "#{success} out of #{@options[:batch_size]} successful" }
  end
end
