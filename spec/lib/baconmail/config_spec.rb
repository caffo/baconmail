RSpec.describe Baconmail::Config do
  it "is initialized with use_preview, bucket, aws_key, aws_secret, "\
      "google_client_id and google_client_secret" do
    use_preview           = SecureRandom.hex
    bucket                = SecureRandom.hex
    aws_key               = SecureRandom.hex
    aws_secret            = SecureRandom.hex
    google_client_id      = SecureRandom.hex
    google_client_secret  = SecureRandom.hex

    config = described_class.new(
      use_preview, bucket, aws_key, aws_secret,
      google_client_id, google_client_secret
    )

    expect(config.use_preview).to eq(use_preview)
    expect(config.bucket).to eq(bucket)
    expect(config.aws_key).to eq(aws_key)
    expect(config.aws_secret).to eq(aws_secret)
    expect(config.google_client_id).to eq(google_client_id)
    expect(config.google_client_secret).to eq(google_client_secret)
  end
end
