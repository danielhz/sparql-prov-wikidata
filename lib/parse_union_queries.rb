#!/usr/bin/env ruby

require 'fileutils'
require 'json'
require 'pry'

require_relative 'query_json_to_sparql/wikidata.rb'

TEMPLATE = 'union'

Dir["queries/patterns/#{TEMPLATE}/*/*.json"].each do |pattern_file|
  puts pattern_file

  pattern = JSON.parse(File.read(pattern_file))

  parsers = {
    B: Wikidata::TruthyUnionPattern,
    R: Wikidata::ReifiedUnionPattern,
    P: Wikidata::ProvenanceUnionPattern
  }

  parsers.each do |mode, parser_class|
    parser = parser_class.new(pattern['pattern'])

    query_dir = File.join(File.dirname(pattern_file).sub('patterns', 'sparql'), mode.to_s)
    
    FileUtils.mkdir_p(query_dir)

    query_file = File.basename(pattern_file.sub(/.json$/, '.sparql'))

    File.open("#{query_dir}/#{query_file}", 'w') do |query_file|
      query_file.puts parser.sparql_select_query
    end
  end
end

