# frozen_string_literal: true

module Wikidata
  ##
  # A class that generates queries randomly.
  class ProvenanceSnowflakePattern < SnowflakePattern
    def subpattern_class
      ProvenanceStarPattern
    end

    def subpatterns_additional_indent
      2
    end

    def statement_vars
      (1..@subpatterns.map { |s| s.size }.reduce(0, :+)).map do |i|
        [
          "#{@args[:poly]}_Sum_summand_Product_factor_#{i}_Sum",
          "#{@args[:poly]}_Sum_summand_Product_factor_#{i}_Sum_summand_Statement"
        ]
      end.flatten
    end
    
    def sparql_select
      st_vars = statement_vars.map { |var| "#{indent(1)}#{var}" }.join("\n")
      "#{indent(0)}SELECT\n#{indent(1)}#{domain.join(' ')}\n" \
      "#{indent(1)}#{@args[:poly]}_Sum\n" \
      "#{indent(1)}#{@args[:poly]}_Sum_summand_Product\n" \
      "#{st_vars}"
    end

    def statements_bind
      b = @subpatterns.map { |s| s.triple_variables }.flatten(1)
      (0...b.size).map do |i|
        bind_mapping(variables: b[i],
                     suffix: "Sum_summand_Product_factor_#{i + 1}_Sum")
      end
    end

    def sparql_where
      [
        "#{indent(0)}WHERE {",
        "#{indent(1)}{",
        "#{@subpatterns.map { |s| s.sparql_pattern }.join(" . \n")}",
        "#{indent(1)}}",
        statements_bind,
        "#{bind_mapping(variables: subpatterns_domain, suffix: 'Sum_summand_Product')}",
        "#{bind_mapping(variables: domain, suffix: 'Sum')}",
        "#{indent(0)}}"
      ].flatten.join("\n")
    end
  end
end
