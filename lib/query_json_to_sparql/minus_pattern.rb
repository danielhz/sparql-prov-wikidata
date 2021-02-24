# frozen_string_literal: true

module Wikidata
  ##
  # A class that generates queries randomly.
  class MinusPattern < GraphPattern
    def initialize(pattern_data, **args)
      super(pattern_data, **args)
      @args = { poly: '?p' }.merge(@args)
      sub_args1 = @args.merge(
          {
            indent: @args[:indent] + subpatterns_additional_indent,
            poly: "#{@args[:poly]}_Sum_summand_Minus_minuend"
          }
        )
      @pattern1 = subpattern_class.new(@pattern_data['pattern1']['pattern'],
                                       **sub_args1)
      sub_args2 = @args.merge(
          {
            indent: @args[:indent] + subpatterns_additional_indent,
            poly: "#{@args[:poly]}_Sum_summand_Minus_subtrahend_Sum_summand"
          }
        )
      @pattern2 = subpattern_class.new(@pattern_data['pattern2']['pattern'],
                                       **sub_args2)
    end

    def prefixes
      (@pattern1.prefixes + @pattern2.prefixes).uniq
    end

    def domain
      @pattern_data['projected']
    end

    def sparql_where
      "#{indent(0)}WHERE {\n" \
      "#{indent(1)}{\n" \
      "#{@pattern1.sparql_pattern}\n" \
      "#{indent(1)}}\n#{indent(1)}MINUS\n#{indent(1)}{\n" \
      "#{@pattern2.sparql_pattern}\n" \
      "#{indent(1)}}\n#{indent(0)}}"
    end

    def sparql_pattern
      [ sparql_select, sparql_where ].join("\n")
    end

    def sparql_select_query
      [ sparql_prefixes, sparql_select, sparql_where ].join("\n")
    end

    def subpatterns_additional_indent
      2
    end
  end
end
