# encoding: UTF-8
module Baconmail
  Config = Struct.new(
    :use_preview, :bucket, :aws_key, :aws_secret,
    :google_client_id, :google_client_secret
  )
end
