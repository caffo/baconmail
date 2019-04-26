RSpec.describe Baconmail::Account do
  it "is initialized with username and email" do
    username  = SecureRandom.hex
    email     = SecureRandom.hex

    account = described_class.new(username, email)

    expect(account.username).to eq(username)
    expect(account.email).to eq(email)
  end
end
