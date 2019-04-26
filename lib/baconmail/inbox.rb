# encoding: UTF-8
module Baconmail
  class Inbox
    attr_reader :account

    def initialize(account)
      @account = account
    end

    def process_inbox!
      log.info("Account: #{account.username}")

      Array(get_emails).each do |email|
        message = gmail.get_user_message("me", email.id, format: 'full')
        label_name = get_mailbox_name(message)
        label_id = find_or_create_label(label_name)

        forward_email(label_name, message) if first_email_with_label?(label_name, message)

        add_label(label_id, message)
        archive(message)

        subject = message.payload.headers.find {|h| h.name == "Subject" }.value
        log.info("\tProcessing #{subject}")
      end

      log.info("Process finished")
    end

    def get_emails(query = "in:inbox is:unread")
      gmail.list_user_messages("me", q: query).messages
    end

    def get_mailbox_name(email)
      to = email.payload.headers.find {|h| h.name == "To" }.value
      address = Mail::Address.new(to).address
      address.split("@").first.downcase
    rescue => e
      log.info("Couldn't get mailbox name for #{email}: #{e}")

      "unknown"
    end

    def get_message(email)
      gmail.get_user_message("me", email.id, format: 'full')
    end

    def forward_email(mailbox, email)
      log.info("First email for [#{mailbox}], forwarding..")

      email_subject = email.payload.headers.find {|h| h.name == "Subject" }.value
      fwd_subject   = "New Sender: #{email_subject}"

      email_body    = email.payload.body&.data

      if email_body.nil?
        html_part   = email.payload.parts.find { |part| part.mime_type == "text/html" }
        text_part   = email.payload.parts.find { |part| part.mime_type == "text/plain" }
        email_body  = (html_part || text_part).body.data
      end

      fwd_body      = "-------------------------- BACONMAIL ----------------------------------<br/>
      You have received a message from : #{mailbox}<br/>
      We have created a new label : #{mailbox}<br/>
      -------------------------- BACONMAIL ----------------------------------<br/><br/>" + email_body

      mail  = Mail.new(body: fwd_body, to: account.email, subject: fwd_subject, content_type: "text/html")
      fwd   = Gmail::Message.new(raw: mail.encoded)

      gmail.send_user_message("me", fwd)
    end

    def gmail
      @gmail ||= Baconmail.authorized_gmail(account.username)
    end

    def log
      @log ||= Baconmail.logger
    end

    def find_or_create_label(label_name)
      existing_labels[label_name] || create_label(label_name)
    end

    def create_label(label_name)
      label = gmail.create_user_label("me", Gmail::Label.new(name: label_name))
      existing_labels[label_name] = label.id
    end

    def existing_labels
      @existing_labels ||= gmail.list_user_labels("me").labels.inject({}) do |cache, label|
        cache[label.name] = label.id
        cache
      end
    end

    def first_email_with_label?(label_name, email)
      query = "in:inbox label:#{label_name} before:#{email.internal_date}"

      get_emails(query).nil?
    end

    def add_label(label_id, message)
      request = Gmail::ModifyMessageRequest.new(add_label_ids: [label_id])
      gmail.modify_message("me", message.id, request)
    end

    def archive(message)
      request = Gmail::ModifyMessageRequest.new(remove_label_ids: ["INBOX"])
      gmail.modify_message("me", message.id, request)
    end
  end
end
