# frozen_string_literal: true

module Wikidata
  ##
  # A class that generates queries randomly.
  class TruthyStarPattern < StarPattern
    def prefixes
      [:wd, :wdt]
    end
 
    def sparql_pattern
      center = @pattern_data['center']
      e = @pattern_data['edges'].map do |edge|
        "#{indent(1)}#{Wikidata.entity_id(edge['predicate'], 'wdt:P')} " \
        "#{Wikidata.entity_id(edge['object'], 'wd:Q')}"
      end.join(" ;\n")
      "#{indent(0)}#{Wikidata.entity_id(center, 'wd:Q')}\n#{e}"
    end
  end
end
