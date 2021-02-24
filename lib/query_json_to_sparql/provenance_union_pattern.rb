# frozen_string_literal: true

module Wikidata
  ##
  # A class that generates queries randomly.
  class ProvenanceUnionPattern < UnionPattern
    def subpattern_class
      ProvenanceSnowflakePattern
    end

    def subpatterns_additional_indent
      3
    end

    def domain
      @subpatterns.map { |s| s.domain }.flatten.uniq
    end

    def sparql_select
      st_vars = @subpatterns
                  .map { |s| s.statement_vars }.flatten
                  .map { |var| "#{indent(1)}#{var}" }
                  .join("\n")
      "#{indent(0)}SELECT\n#{indent(1)}#{domain.join(' ')}\n" \
      "#{indent(1)}#{@args[:poly]}_Add\n" \
      "#{indent(1)}#{@args[:poly]}_Add_summand_1_Sum\n" \
      "#{indent(1)}#{@args[:poly]}_Add_summand_1_Sum_summand_Product\n" \
      "#{indent(1)}#{@args[:poly]}_Add_summand_1_Sum\n" \
      "#{indent(1)}#{@args[:poly]}_Add_summand_1_Sum_summand_Product\n" \
      "#{st_vars}"
    end

    def sparql_where
      subpatterns_sparql = @subpatterns.map do |subpattern|
        "#{indent(2)}{\n#{subpattern.sparql_pattern}\n#{indent(2)}}"
      end.join("\n#{indent(2)}UNION\n")

      [
        "#{indent(0)}WHERE {",
        "#{indent(1)}{\n#{subpatterns_sparql}\n#{indent(1)}}",
        bind_mapping(variables: domain, suffix: 'Add'),
        '}'
      ].flatten.map { |x| "#{indent(0)}#{x}" }.join("\n")
    end
  end
end
