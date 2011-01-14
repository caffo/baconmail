require 'rubygems'
require 'gmail'
require 'logger'
require "date"

class Anotherinbox < Object
  def self.process_inbox!(email_address, password, target_email)
    log = Logger.new(STDOUT)
    log.info("Account: #{email_address}")
    Gmail.new(email_address, password) do |gmail|
      gmail.inbox.emails(:unread).each do |email|
        mailbox = email[:to][0].mailbox.downcase rescue "unknown"
        gmail.labels.new(mailbox)
        if gmail.mailbox(mailbox).count == 0
          log.info("First email for [#{gmail.mailbox(mailbox)}], forwarding..")
          fwd                 = gmail.message
          fwd.to              = target_email
          fwd.subject         = email.subject
          fwd.content_type    = "text/html"
          fwd.body            = email.parts.last.body.to_s rescue nil
          fwd.body          ||= email.body.to_s
          fwd.deliver!
        end
        email.label(mailbox)
        email.unread!
        log.info("\tProcessing #{email[:subject]}")
      end
    end
    log.info("Process finished")
  end

  def self.daily_digest(email_address, password, target_email)
    def self.email_template(new_messages)
      response = ""
      response += "<h1>Daily Digest for #{Date.yesterday}</h1>"
      new_messages.each {|m| response += "<li>#{m[0]}: <strong>#{m[1]}</strong> </li>"}
      return response
    end

    log = Logger.new(STDOUT)
    log.info("Account: #{email_address}")
    emails = []
    Gmail.new(email_address, password) do |gmail|
      gmail.inbox.emails(:on => Date.yesterday).each do |email|
        mailbox = email[:to][0].mailbox.downcase rescue "unknown"
        emails << [mailbox, email.subject]
      end

      if emails.size > 0
        log.info("Sending daily digest with #{emails.size} entries..")
        digest                 = gmail.message
        digest.to              = target_email
        digest.subject         = "Daily Digest for #{Date.yesterday}"
        digest.content_type    = "text/html"
        digest.body            = self.email_template(emails)
        digest.deliver!
      end
    end
    log.info("Process finished")
  end
end