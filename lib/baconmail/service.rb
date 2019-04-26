module Baconmail
  class Service
    attr_reader :account

    def initialize(account)
      @account = account
    end

    def get_emails(query = "in:inbox is:unread")
      email_list = gmail.list_user_messages("me", q: query)
      Array(email_list.messages)
    end

    def get_mailbox_name(email)
      to = read_header(email, "To")
      address = Mail::Address.new(to).address
      address.split("@").first.downcase
    rescue => e
      log.info("Couldn't get mailbox name for #{email}: #{e}")

      "unknown"
    end

    def log
      @log ||= Baconmail.logger
    end

    def gmail
      @gmail ||= Baconmail.authorized_gmail(account.username)
    end

    def get_full_message(id)
      gmail.get_user_message("me", id, format: 'full')
    end

    def retrieve_body(email)
      email_body = email.payload.body&.data

      email_body ||= begin
        html_part = email.payload.parts.find { |part| part.mime_type == "text/html" }
        text_part = email.payload.parts.find { |part| part.mime_type == "text/plain" }
        (html_part || text_part).body.data
      end
    end

    def read_header(email, header)
      email.payload.headers.find {|h| h.name == header }&.value
    end

    def compose_message(attrs)
      attrs[:content_type] ||= "text/html"

      mail = Mail.new(attrs)

      Gmail::Message.new(raw: mail.encoded)
    end

    def configs
      Baconmail::Settings.instance.config
    end
  end
end
