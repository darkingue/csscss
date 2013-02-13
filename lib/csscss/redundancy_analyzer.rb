class Csscss::RedundancyAnalyzer
  include Csscss

  def initialize(raw_css)
    @raw_css = raw_css
  end

  def redundancies
    rule_sets = CSSPool.CSS(@raw_css).rule_sets
    matches = {}
    rule_sets.each {|rs| downcase_all_expressions(rs) }
    rule_sets.combination(2) do |rule_set1, rule_set2|
      same_decs = rule_set1.declarations.select do |dec|
        rule_set2.declarations.include?(dec)
      end

      unless same_decs.empty?
        same_decs = same_decs.map {|dec| Declaration.from_csspool(dec) }

        matches[rule_set1] ||= []
        matches[rule_set1] << RuleSet.new(rule_set2.selectors.map(&:to_s), same_decs)
      end
    end

    matches.map {|rule_set, raw_matches| Match.new(RuleSet.from_csspool(rule_set), raw_matches) }
  end

  private
  def downcase_all_expressions(rule_set)
    rule_set.declarations.each {|dec| dec.property.downcase! }
  end
end
