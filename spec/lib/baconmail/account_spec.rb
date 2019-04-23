RSpec.describe Baconmail::Account do
  it "is initialized with username, password and email" do
    username  = SecureRandom.hex
    email     = SecureRandom.hex
    password  = SecureRandom.hex

    account = described_class.new(username, password, email)

    expect(account.username).to eq(username)
    expect(account.password).to eq(password)
    expect(account.email).to eq(email)
  end
end
