# encoding: UTF-8
require 'google/apis/gmail_v1'
require 'logger'
require 'date'
require 'mail'
require 'digest/sha1'
require 'aws/s3'
require 'yaml'
require 'singleton'
require 'baconmail/object'
require 'baconmail/service'
require 'baconmail/account'
require 'baconmail/authorizer'
require 'baconmail/config'
require 'baconmail/settings'
require 'baconmail/inbox'
require 'baconmail/digest'

module Baconmail
  Gmail = Google::Apis::GmailV1

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.authorized_gmail(username)
    Gmail::GmailService.new.tap do |g|
      g.authorization = Authorizer.credentials(username)
      g.client_options.application_name = 'Baconmail'
    end
  end
end
