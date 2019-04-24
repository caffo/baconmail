RSpec.describe Baconmail::Inbox do
  let(:account) { Baconmail::Account.new("", "", "") }

  describe "#process_inbox!" do
    let(:inbox) { described_class.new(account) }
    let(:mailbox) { "inbox" }
    let(:fake_gmail) { FakeGmail.new }
    let(:email) { fake_gmail.emails.first }

    before do
      allow(inbox).to receive(:gmail).and_return(fake_gmail)
    end

    it "finds the name of the mailbox" do
      expect(inbox).to receive(:find_mailbox_name).with(email).and_return(mailbox)

      inbox.process_inbox!
    end

    it "creates a label" do
      label = "INBOX"
      allow(inbox).to receive(:find_mailbox_name).with(email).and_return(label)
      expect(inbox).to receive(:create_label).with(label)

      inbox.process_inbox!
    end

    context "when the email is first in the mailbox" do
      it "forwards the email" do
        allow(inbox).to receive(:first_email?).with(mailbox).and_return(true)

        expect(inbox).to receive(:forward_email).with(mailbox, email)

        inbox.process_inbox!
      end
    end

    context "when the email is not first in the mailbox" do
      it "doesn't forward the email" do
        allow(inbox).to receive(:first_email?).with(mailbox).and_return(false)

        expect(inbox).to_not receive(:forward_email)

        inbox.process_inbox!
      end
    end

    it "labels the email" do
      expect(email).to receive(:label).with(mailbox)

      inbox.process_inbox!
    end

    it "marks the email as unread" do
      expect(email).to receive(:unread!)

      inbox.process_inbox!
    end

    it "archives the email" do
      expect(email).to receive(:archive!)

      inbox.process_inbox!
    end
  end
end
