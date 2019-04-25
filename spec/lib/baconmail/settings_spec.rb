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
        "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
        "682174746236-k25ubsois96bfah7mbnfa5texample.apps.googleusercontent.com",
        "_IDLjNKfRsoXHGXG3exampl3"
      )

      expect(settings.config).to eq(config)
    end

    it "sets the blacklist" do
      expect(settings.blacklist).to eq(["facebook", "microsoft"])
    end
  end
end
