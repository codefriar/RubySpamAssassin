require_relative '../spec_helper'

describe RubySpamAssassin::SpamClient do
  it "does not open a socket at initialization" do
    expect(TCPSocket).not_to receive(:open)
    RubySpamAssassin::SpamClient.new
  end

  describe "#send" do
    let(:socket) { instance_double("TCPSocket", readlines: [[]]).as_null_object }

    it "opens a socket on every request" do
      expect(TCPSocket).to receive(:open).and_return(socket)
      subject.ping
    end

    it "closes the socket on every request" do
      allow(TCPSocket).to receive(:open).and_return(socket)
      expect(socket).to receive(:close)
      subject.ping
    end

    it "even closes the socket in case of an exception during the request" do
      allow(TCPSocket).to receive(:open).and_return(socket)
      allow(socket).to receive(:write).and_raise("Some error")
      expect(socket).to receive(:close)
      expect { subject.ping }.to raise_error "Some error"
    end
  end
end
