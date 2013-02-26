# encoding: UTF-8
module Baconmail
  Config = Struct.new(:use_preview, :bucket, :aws_key, :aws_secret)
end