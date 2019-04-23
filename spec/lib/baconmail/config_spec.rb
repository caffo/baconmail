RSpec.describe Baconmail::Config do
  it "is initialized with use_preview, bucket, aws_key and aws_secret" do
    use_preview = SecureRandom.hex
    bucket      = SecureRandom.hex
    aws_key     = SecureRandom.hex
    aws_secret  = SecureRandom.hex

    config = described_class.new(use_preview, bucket, aws_key, aws_secret)

    expect(config.use_preview).to eq(use_preview)
    expect(config.bucket).to eq(bucket)
    expect(config.aws_key).to eq(aws_key)
    expect(config.aws_secret).to eq(aws_secret)
  end
end
