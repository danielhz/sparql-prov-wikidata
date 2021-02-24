# frozen_string_literal: true

module Wikidata
  ##
  # A class that generates queries randomly.
  class ReifiedStarPattern < StarPattern
    def prefixes
      [:wd, :p, :ps]
    end

    def sparql_pattern
      center = @pattern_data['center']
      e = @pattern_data['edges'].map do |edge|
        "#{indent(1)}#{Wikidata.entity_id(edge['predicate'], 'p:P')} " \
        "[ #{Wikidata.entity_id(edge['predicate'], 'ps:P')} " \
        "#{Wikidata.entity_id(edge['object'], 'wd:Q')} ]"
      end.join(" ;\n")
      "#{indent(0)}#{Wikidata.entity_id(center, 'wd:Q')}\n#{e}"
    end
  end
end
