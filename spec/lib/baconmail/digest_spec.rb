RSpec.describe Baconmail::Digest do
  let(:account) { Baconmail::Account.new("", "", "") }
  let(:configs) { Baconmail::Settings.instance.config }
  let(:digest) { described_class.new(account, configs) }
  let(:fake_gmail) { FakeGmail.new }
  let(:email) { fake_gmail.emails.first }

  before do
    allow(digest).to receive(:gmail).and_return(fake_gmail)
  end

  describe "#daily_digest" do
    context "when an email is a digest" do
      it "doesn't include the email in digest" do
        allow(digest).to receive(:digest?).with(email).and_return(true)

        expect(digest).to_not receive(:send_digest)

        digest.daily_digest
      end
    end

    context "when an email was sent from the same account" do
      it "doesn't include the email in digest" do
        allow(digest).to receive(:from_me?).with(email).and_return(true)

        expect(digest).to_not receive(:send_digest)

        digest.daily_digest
      end
    end

    context "when email is not a digest and sent from another account" do
      it "includes the email in digest" do
        digest_emails = [["inbox", email.subject, email.body]]

        expect(digest).to receive(:send_digest).with(digest_emails)

        digest.daily_digest
      end
    end
  end
end
