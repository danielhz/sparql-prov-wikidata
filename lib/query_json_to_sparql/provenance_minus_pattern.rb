# frozen_string_literal: true

module Wikidata
  ##
  # A class that generates queries randomly.
  class ProvenanceMinusPattern < MinusPattern
    def subpattern_class
      ProvenanceStarPattern
    end

    def statement_var(pattern, i)
      case pattern
      when :minuend_Sum
        "#{@args[:poly]}_Sum_summand_Minus_minuend_Product_factor_#{i}_Sum"
      when :minuend_Statement
        "#{@args[:poly]}_Sum_summand_Minus_minuend_Product_factor_#{i}_Sum_summand_Statement"
      when :subtrahend_Sum
        "#{@args[:poly]}_Sum_summand_Minus_subtrahend_Sum_summand_Product_factor_#{i}_Sum"
      when :subtrahend_Statement
        "#{@args[:poly]}_Sum_summand_Minus_subtrahend_Sum_summand_Product_factor_#{i}_Sum_summand_Statement"
      end
    end

    def statement_vars
      vars1 = (1..@pattern1.size).map do |i|
        [ statement_var(:minuend_Sum, i), statement_var(:minuend_Statement, i) ]
      end
      vars2 = (1..@pattern2.size).map do |i|
        [ statement_var(:subtrahend_Sum, i), statement_var(:subtrahend_Statement, i) ]
      end
      [
        "#{@args[:poly]}_Sum_summand_Minus_minuend_Product",
        vars1,
        "#{@args[:poly]}_Sum_summand_Minus_subtrahend_Sum_summand_Product",
        vars2,
      ].flatten
    end
    
    def sparql_select
      st_vars = statement_vars.map { |var| "#{indent(1)}#{var}" }.join("\n")
      "#{indent(0)}SELECT\n#{indent(1)}#{domain.join(' ')}\n" \
      "#{indent(1)}#{@args[:poly]}_Sum\n" \
      "#{indent(1)}#{@args[:poly]}_Sum_summand_Minus\n" \
      "#{st_vars}"
    end

    def pattern1_statements_bind
      b = @pattern1.triple_variables
      (0...b.size).map do |i|
        bind_mapping(variables: b[i],
                     suffix: "Sum_summand_Minus_minuend_Product_factor_#{i + 1}_Sum")
      end
    end

    def pattern2_statements_bind
      b = @pattern2.triple_variables
      (0...b.size).map do |i|
        bind_mapping(variables: b[i],
                     suffix: "Sum_summand_Minus_subtrahend_Sum_summand_Product_factor_#{i + 1}_Sum")
      end
    end
    
    def statements_bind
      [ bind_mapping(variables: self.domain,
                     suffix: "Sum"),
        bind_mapping(variables: @pattern1.domain,
                     suffix: "Sum_summand_Minus"),
        "#{indent(1)}BIND (#{@args[:poly]}_Sum_summand_Minus AS \n" \
        "#{indent(1)}      #{@args[:poly]}_Sum_summand_Minus_minuend_Product)",
        pattern1_statements_bind,
        "#{indent(1)}BIND (#{@args[:poly]}_Sum_summand_Minus AS \n" \
        "#{indent(1)}      #{@args[:poly]}_Sum_summand_Minus_subtrahend_Sum)",
        bind_mapping(variables: @pattern2.domain,
                     suffix: "Sum_summand_Minus_subtrahend_Sum_summand_Product"),
        pattern2_statements_bind
      ].flatten
    end

    def sparql_where
      [
        "#{indent(0)}WHERE {",
        "#{indent(1)}{",
        "#{indent(2)}{",
        "#{@pattern1.sparql_pattern}",
        "#{indent(2)}}\n#{indent(1)}OPTIONAL\n#{indent(2)}{",
        "#{@pattern2.sparql_pattern}",
        "#{indent(2)}}\n#{indent(1)}}",
        *statements_bind,
        "#{indent(0)}}"
      ].flatten.join("\n")
    end

    # def sparql_where
    #   [
    #     "#{indent(0)}WHERE {",
    #     "#{indent(1)}{",
    #     "#{@subpatterns.map { |s| s.sparql_pattern }.join(" . \n")}",
    #     "#{indent(1)}}",
    #     statements_bind,
    #     "#{bind_mapping(variables: subpatterns_domain, suffix: 'Sum_summand_Product')}",
    #     "#{bind_mapping(variables: domain, suffix: 'Sum')}",
    #     "#{indent(0)}}"
    #   ].flatten.join("\n")
    # end
    
    def subpatterns_additional_indent
      3
    end
  end
end
