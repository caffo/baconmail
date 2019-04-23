RSpec.describe Baconmail::Settings do
  describe "#initialize" do
    let(:settings) { described_class.instance }

    it "sets the accounts" do
      accounts = [
        Baconmail::Account.new('caconmail@gmail.com', 'password42', 'personal@email.com'),
        Baconmail::Account.new('anotherbaconmail@gmail.com', 'password42!', 'personal2@email.com')
      ]

      expect(settings.accounts).to eq(accounts)
    end

    it "sets the config" do
      config = Baconmail::Config.new(
        false,
        "baconmail.amazon.bucket",
        "AKIAIOSFODNN7EXAMPLE",
        "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
      )

      expect(settings.config).to eq(config)
    end
  end
end
