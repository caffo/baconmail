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
          fwd.subject         = "New Sender: #{email.subject}"
          fwd.content_type    = "text/html"
          body                = email.parts.last.body.to_s rescue nil
          body              ||= email.body.to_s
          fwd.body            = "-------------------------- ANOTHERINBOX ----------------------------------<br/>
          You have received a message from : #{mailbox}<br/>
          We have created a new label : #{mailbox}<br/>
          -------------------------- ANOTHERINBOX ----------------------------------<br/><br/>" + body
          fwd.deliver!
        end
        email.label(mailbox)
        email.unread!
        email.archive!
        log.info("\tProcessing #{email[:subject]}")
      end
    end
    log.info("Process finished")
  end

  def self.daily_digest(email_address, password, target_email)
    def self.email_template(new_messages, account)
      # we all know, inline styles sucks. sadly, it's the
      # only way to get them into gmail.
      response = ""
      response += "<h1 style='margin-left: 40px; color: #000000;'>Daily Digest for #{Date.yesterday}</h1>"
      response += "<h3 style='color: #aaaaaa; margin-left: 40px; margin-top: -20px; margin-bottom: 30px;'>for #{account}</h3>"
      response += "<ul style='width: 90%;'>"
      new_messages.sort.each {|m| response += "<li style='margin-bottom: 10px; list-style: none; color: #3485ae; border-bottom: 1px dotted #ccc; padding-bottom: 10px; font-weight: bold;'>#{m[0]}: <strong style='color: #000000; font-weight: normal;'>#{m[1]}</strong> </li>"}
      response += "</ul>"
      return response
    end

    log         = Logger.new(STDOUT)
    emails      = []
    aib_domain  = email_address.split("@")[1]

    Gmail.new(email_address, password) do |gmail|
      gmail.mailbox('[Gmail]/All Mail').emails(:on => Date.yesterday).each do |email|
        next if email.subject.match("Daily Digest for") rescue nil
        next if "#{email.from[0]['mailbox']}@#{email.from[0]['host']}" == email_address
        mailbox = email[:to][0].mailbox.downcase rescue "unknown"
        emails << [mailbox, email.subject]
      end

      if emails.size > 0
              log.info("Sending daily digest with #{emails.size} entries..")
              digest                 = gmail.message
              digest.to              = target_email
              digest.subject         = "[#{aib_domain}] Daily Digest for #{Date.yesterday}"
              digest.content_type    = "text/html"
              digest.body            = self.email_template(emails, aib_domain)
              digest.deliver!
            end
    end
    log.info("Process finished")
  end
end