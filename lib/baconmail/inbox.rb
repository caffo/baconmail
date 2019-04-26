# encoding: UTF-8
module Baconmail
  class Inbox < Service
    def process_inbox!
      log.info("Account: #{account.username}")

      get_emails.each do |email|
        message     = get_full_message(email.id)
        label_name  = get_mailbox_name(message)
        label_id    = find_or_create_label(label_name)

        if first_email_with_label?(message, label_name)
          forward_email(label_name, message)
        end

        add_label(label_id, message)
        archive(message)

        log.info("\tProcessing #{read_header(message, "Subject")}")
      end

      log.info("Process finished")
    end

    def forward_email(mailbox, email)
      log.info("First email for [#{mailbox}], forwarding..")

      fwd_subject   = "New Sender: #{read_header(email, "Subject")}"
      email_body    = retrieve_body(email)

      fwd_body =
        "-------------------------- BACONMAIL ----------------------------------<br/>
        You have received a message from : #{mailbox}<br/>
        We have created a new label : #{mailbox}<br/>
        -------------------------- BACONMAIL ----------------------------------<br/>
        <br/>
        #{email_body}"

      fwd = compose_message(body: fwd_body, to: account.email, subject: fwd_subject)

      gmail.send_user_message("me", fwd)
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

    def first_email_with_label?(email, label_name)
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
