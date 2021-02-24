# frozen_string_literal: true

module Wikidata
  ##
  # A class that generates queries randomly.
  class GraphPattern
    def initialize(pattern_data, **args)
      @pattern_data = pattern_data
      @args = { indent: 0 }.merge(args)
    end

    def indent(steps = 0)
      '  ' * (@args[:indent] + steps)
    end

    def sparql_prefixes
      "#{indent(0)}#{Wikidata.sparql_prefixes(*prefixes)}"
    end

    def sparql_select
      "#{indent(0)}SELECT #{domain.join(' ')}"
    end

    def sparql_select_query
      [ sparql_prefixes, sparql_select, sparql_pattern ].join("\n")
    end

    def bind_mapping(variables: domain, suffix:)
      mapping = variables.map do |var|
        v = var.gsub('?', '')
        "#{v}=\",ENCODE_FOR_URI(#{var})"
      end.join(",\n#{indent(2)}\"&")
      bind_var = "#{@args[:poly]}_#{suffix}"

      "#{indent(1)}BIND (URI(concat(\n" \
      "#{indent(2)}\"http://example.org/#{bind_var.gsub('?','')}/\",\n" \
      "#{indent(2)}\"?#{mapping}\n" \
      "#{indent(1)})) AS #{bind_var})"
    end
  end
end
