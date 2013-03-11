require_relative '../spec_helper'

describe "ReportParser" do
  it "should parse the report text into an informative hash" do
    spam = File.read('spec/data/spam_test1.txt')
    result = RubySpamAssassin::ReportParser.parse(spam)
    result.length.equal?(6)

    # Check contents of first one to make sure text/points are formatted correctly
    result[0][:pts].equal?(0.5)
    result[0][:rule].equal?('DATE_IN_PAST_24_48')
    result[0][:text].equal?('Date: is 24 to 48 hours before Received: date')
  end
end
