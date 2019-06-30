class RubySpamAssassin::ReportParser
  LINE_REGEXP = /-$/
  RULE_REGEXP = /^[-|\s]?[0-9]*[.][0-9]\s\w*\s/

  def self.parse(report_text)
    last_part = report_text.split(LINE_REGEXP)[1].sub(/^[\n\r]/,'').chomp.chomp
    pts_rules = last_part.gsub(RULE_REGEXP).collect { |sub| sub.chomp(' ') }
    rule_texts = last_part.split(RULE_REGEXP).collect { |text| text.delete("\n").squeeze(' ').strip }

    rules = []
    pts_rules.each_with_index do |pts_rule, i|
      rules << {
        :pts => pts_rule.split(' ')[0].to_f,
        :rule => pts_rule.split(' ')[1],
        :text => rule_texts[i + 1]
      }
    end

    rules
  end
end