# encoding: UTF-8
module Baconmail
  class Inbox
    attr_reader :account

    def initialize(account)
      @account = account
    end

    def process_inbox!
      log.info("Account: #{account.username}")

      emails.each do |email|
        mailbox = find_mailbox_name(email)
        create_label(mailbox)

        forward_email(mailbox, email) if first_email?(mailbox)

        email.label(mailbox)
        email.unread!
        email.archive!

        log.info("\tProcessing #{email[:subject]}")
      end

      log.info("Process finished")
    end

    def emails
      gmail.mailbox('[Gmail]/All Mail').emails(gm: 'in:inbox label: unread')
    end

    def find_mailbox_name(email)
      email[:to].find do |mail|
        mail.host == account.username.split("@").last
      end.mailbox.downcase
    rescue => e
      "unknown"
    end

    def forward_email(mailbox, email)
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

    def gmail
      @gmail ||= Gmail.new(account.username, account.password)
    end

    def log
      @log ||= Logger.new(STDOUT)
    end

    def create_label(label)
      gmail.labels.new(label)
    end

    def first_email?(mailbox)
      gmail.mailbox(mailbox).count == 0
    end
  end
end
