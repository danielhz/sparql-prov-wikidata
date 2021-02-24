# frozen_string_literal: true

require_relative 'graph_pattern'
require_relative 'star_pattern'
require_relative 'truthy_star_pattern'
require_relative 'reified_star_pattern'
require_relative 'provenance_star_pattern'
require_relative 'snowflake_pattern'
require_relative 'truthy_snowflake_pattern'
require_relative 'reified_snowflake_pattern'
require_relative 'provenance_snowflake_pattern'
require_relative 'union_pattern'
require_relative 'truthy_union_pattern'
require_relative 'reified_union_pattern'
require_relative 'provenance_union_pattern'
require_relative 'minus_pattern'
require_relative 'truthy_minus_pattern'
require_relative 'reified_minus_pattern'
require_relative 'provenance_minus_pattern'

module Wikidata
  PREFIX = {
    wd: 'http://www.wikidata.org/entity/',
    wdt: 'http://www.wikidata.org/prop/direct/',
    p: 'http://www.wikidata.org/prop/',
    ps: 'http://www.wikidata.org/prop/statement/'
  }.freeze

  def self.sparql_prefixes(*names)
    names.map do |name|
      "PREFIX #{name}: <#{PREFIX[name]}>"
    end.join("\n")
  end

  def self.entity_id(entity, prefix)
    case entity
    when String
      entity
    when Integer
      "#{prefix}#{entity}"
    end
  end
end
