# frozen_string_literal: true

module Wikidata
  ##
  # A class that generates queries randomly.
  class TruthyMinusPattern < MinusPattern
    def subpattern_class
      TruthyStarPattern
    end
  end
end
