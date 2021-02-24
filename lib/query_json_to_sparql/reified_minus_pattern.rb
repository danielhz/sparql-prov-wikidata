# frozen_string_literal: true

module Wikidata
  ##
  # A class that generates queries randomly.
  class ReifiedMinusPattern < MinusPattern
    def subpattern_class
      ReifiedStarPattern
    end
  end
end
