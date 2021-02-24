# frozen_string_literal: true

module Wikidata
  ##
  # A class that generates queries randomly.
  class TruthyUnionPattern < UnionPattern
    def subpattern_class
      TruthySnowflakePattern
    end
  end
end
