# frozen_string_literal: true

module Wikidata
  ##
  # A class that generates queries randomly.
  class SnowflakePattern < GraphPattern
    def initialize(pattern_data, **args)
      super(pattern_data, **args)
      @args = { poly: '?p' }.merge(@args)
      first_statement = 1
      
      @subpatterns = @pattern_data['subpatterns'].map do |subpattern|
        sub_args = @args.merge(
          {
            indent: @args[:indent] + subpatterns_additional_indent,
            poly: "#{@args[:poly]}_Sum_summand",
            first_statement: first_statement
          }
        )
        first_statement += subpattern['pattern']['edges'].size
        subpattern_class.new(subpattern['pattern'], **sub_args)
      end
    end

    def subpatterns_additional_indent
      1
    end
    
    def prefixes
      @subpatterns.map{ |s| s.prefixes }.reduce([], :concat).uniq
    end
    
    def domain
      @pattern_data['projected']
    end

    def subpatterns_domain
      @subpatterns.map { |s| s.domain }.reduce([], :concat).uniq
    end

    def sparql_where
      subpatterns_sparql = @subpatterns.map do |subpattern|
        subpattern.sparql_pattern
      end.join(" . \n")
      "#{indent(0)}WHERE {\n" \
      "#{subpatterns_sparql}\n#{indent(0)}}"
    end
    
    def sparql_pattern
      [ sparql_select, sparql_where ].join("\n")
    end

    def sparql_select_query
      [ sparql_prefixes, sparql_select, sparql_where ].join("\n")
    end
  end
end
