# frozen_string_literal: true

module Wikidata
  ##
  # A class that generates queries randomly.
  class StarPattern < GraphPattern
    def domain
      vars = [@pattern_data['center']]
      @pattern_data['edges'].each do |edge|
        obj = edge['object']
        vars.append(obj) if obj.class == String
      end
      vars.sort
    end

    def size
      @pattern_data['edges'].size
    end

    def triple_variables
      @pattern_data['edges'].map do |edge|
        v = [@pattern_data['center']]
        v.append(edge['object']) if edge['object'].class == String
        v
      end
    end
  end
end
