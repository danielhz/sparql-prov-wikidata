# frozen_string_literal: true

module Wikidata
  ##
  # A class that generates queries randomly.
  class UnionPattern < GraphPattern
    def initialize(pattern_data, **args)
      super(pattern_data, **args)
      @args = { poly: '?p' }.merge(@args)
      @subpatterns = (0...@pattern_data['subpatterns'].size).map do |i|
        subpattern = @pattern_data['subpatterns'][i]
        sub_args = @args.merge(
          {
            indent: @args[:indent] + subpatterns_additional_indent,
            poly: "#{@args[:poly]}_Add_summand_#{i + 1}"
          }
        )
        subpattern_class.new(subpattern['pattern'], **sub_args)
      end
    end

    def subpatterns_additional_indent
      2
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

    def sparql_prefixes
      "#{indent(0)}#{Wikidata.sparql_prefixes(*prefixes)}"
    end

    def sparql_select
      "#{indent(0)}SELECT *"
    end

    def sparql_where
      subpatterns_sparql = @subpatterns.map do |subpattern|
        "#{indent(1)}{\n#{subpattern.sparql_pattern}\n#{indent(1)}}"
      end.join("\n#{indent(1)}UNION\n")
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
