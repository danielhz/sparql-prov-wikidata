# frozen_string_literal: true

module Wikidata
  ##
  # A class that generates queries randomly.
  class ProvenanceStarPattern < StarPattern

    def initialize(pattern_data, **args)
      super(pattern_data, **args)
      @args = { first_statement: 1 }.merge(args)
    end

    def prefixes
      [:wd, :p, :ps]
    end
    
    def sparql_pattern
      center = @pattern_data['center']
      edges = @pattern_data['edges']
      e = (0...edges.size).map do |i|
        edge = edges[i]
        st = "#{@args[:poly]}_Product_factor_#{@args[:first_statement] + i}_Sum_summand_Statement"
        "#{indent(0)}#{center} #{Wikidata.entity_id(edge['predicate'], 'p:P')} #{st} .\n" \
        "#{indent(0)}#{st} #{Wikidata.entity_id(edge['predicate'], 'ps:P')} " \
        "#{Wikidata.entity_id(edge['object'], 'wd:Q')}"
      end.join(" .\n")
      e
    end
  end
end
