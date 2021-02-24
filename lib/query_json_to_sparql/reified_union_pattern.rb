# frozen_string_literal: true

module Wikidata
  ##
  # A class that generates queries randomly.
  class ReifiedUnionPattern < UnionPattern
    def subpattern_class
      ReifiedSnowflakePattern
    end
  end
end
