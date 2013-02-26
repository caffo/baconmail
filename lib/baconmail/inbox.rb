# encoding: UTF-8
module Baconmail
  class Inbox
    def self.process_inbox!(account)
      log = Logger.new(STDOUT)
      log.info("Account: #{account.username}")
      Gmail.new(account.username, account.password) do |gmail|
        gmail.inbox.emails(:unread).each do |email|
          mailbox = email[:to].detect{|mail| mail.host == account.username.split("@").last}.mailbox.downcase rescue "unknown"
          gmail.labels.new(mailbox)
          if gmail.mailbox(mailbox).count == 0
            log.info("First email for [#{gmail.mailbox(mailbox)}], forwarding..")
            fwd                 = gmail.message
            fwd.to              = account.email
            fwd.subject         = "New Sender: #{email.subject}"
            fwd.content_type    = "text/html"
            body                = email.parts.last.body.to_s rescue nil
            body              ||= email.body.to_s
            fwd.body            = "-------------------------- BACONMAIL ----------------------------------<br/>
            You have received a message from : #{mailbox}<br/>
            We have created a new label : #{mailbox}<br/>
            -------------------------- BACONMAIL ----------------------------------<br/><br/>" + body
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
  end
end