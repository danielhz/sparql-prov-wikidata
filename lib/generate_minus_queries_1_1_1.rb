#!/usr/bin/env ruby

require 'json'
require 'fileutils'
require 'pry'

require './lib/sparql_bench.rb'

RANDOM = Random.new(0)

STAR_SIZE = 3
QUERY_DIR = "queries/patterns/minus/#{'%02d' % STAR_SIZE}"
QUERY_NUM = 100
GEOMETRY = 'minus'

endpoint =  LXDFusekiEndpoint.new('wikidata-20200127-fuseki3-ubuntu2004')

endpoint.start

query_id = 0

def wd_entity_id(uri)
  uri.sub('http://www.wikidata.org/entity/Q', '').to_i
end

def wd_prop_id(uri)
  uri.sub('http://www.wikidata.org/prop/direct/P', '').to_i
end

def pattern_obj(entity_id, pairs)
  doc = {
    meta: {
      type: "Wikidata::MinusQueryGenerator",
      entity_id: entity_id.to_i,
      bindings: pairs
    },
    pattern: {
      projected: ['?x', '?y1'],
      pattern1: {
        meta: {
          type: 'Wikidata::StarQueryGenerator'
        },
        pattern: {
          center: '?x',
          edges: [
            {
              predicate: pairs[0][0],
              object: pairs[0][1],
            },
            {
              predicate: pairs[1][0],
              object: '?y1',
            },
            {
              predicate: pairs[2][0],
              object: '?y2a',
            }
          ]
        }
      },
      pattern2: {
        meta: {
          type: 'Wikidata::StarQueryGenerator'
        },
        pattern: {
          center: '?x',
          edges: [
            {
              predicate: pairs[0][0],
              object: pairs[0][1],
            },
            {
              predicate: pairs[1][0],
              object: '?y1',
            },
            {
              predicate: pairs[2][0],
              object: '?y2b',
            }
          ]
        }
      }      
    }
  }
end

FileUtils.mkdir_p(QUERY_DIR)

Zlib::GzipReader.open('entities/entities-shuffled.gz') do |gz|

  while query_id < QUERY_NUM do
    entity_id = gz.readline.strip

    query = endpoint.sparql.select.distinct
              .where([RDF::URI("http://www.wikidata.org/entity/Q#{entity_id}"), :p, :o])
              .filter('regex(str(?p), "^http://www.wikidata.org/prop/direct/P")')
              .filter('regex(str(?o), "^http://www.wikidata.org/entity/Q")')
              .filter('?p != <http://www.wikidata.org/prop/direct/P31>')

    result = query.solutions

    result_map = {}

    result.each do |solution|      
      prop_id = wd_prop_id(solution[:p].to_s)
      entity_id = wd_entity_id(solution[:o].to_s)

      if result_map.include? prop_id
        result_map[prop_id].append entity_id
      else
        result_map[prop_id] = [entity_id]
      end
    end

    if result_map.size >= STAR_SIZE
      query_id += 1

      pairs = result_map.to_a.shuffle(random: RANDOM)[0...STAR_SIZE]

      pairs.each do |pair|
        pair[1] = pair[1].sample(random: RANDOM)
      end      
     
      File.open("#{QUERY_DIR}/#{'%03d' % query_id}.json", "w") do |query_file|
        query_file.puts JSON.pretty_generate(pattern_obj(entity_id, pairs))
      end      
    else
      next
    end

    puts "Attempt query_id=#{query_id} result_size=#{result.size} entity_id=#{entity_id}"
  end
end

endpoint.stop
