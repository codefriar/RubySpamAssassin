require_relative '../spec_helper'

describe "ReportParser" do
  it "should parse the report text into an informative hash" do
    spam = File.read('spec/data/spam_test1.txt')
    result = RubySpamAssassin::ReportParser.parse(spam)
    expect(result.length).to eq(6)

    # Check contents of first one to make sure text/points are formatted correctly
    expect(result[0][:pts]).to eq(0.5)
    expect(result[0][:rule]).to eq('DATE_IN_PAST_24_48')
    expect(result[0][:text]).to eq('Date: is 24 to 48 hours before Received: date')
  end
end
