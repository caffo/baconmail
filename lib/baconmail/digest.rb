# encoding: UTF-8

class Object
  def to_imap_date
    date = respond_to?(:utc) ? utc.to_s : to_s
    Date.parse(date).strftime('%d-%b-%Y')
  end
end

module Baconmail
  class Digest
    attr_reader :account, :configs

    def initialize(account, configs)
      @account = account
      @configs = configs
    end

    def daily_digest
      log.info("Account: #{account.username}")

      digest_emails = emails.each_with_object([]) do |email, collection|
        next if digest?(email) || from_me?(email)

        mailbox = get_mailbox_name(email)
        body    = email.html_part.nil? ? email.body : email.html_part.body

        collection << [mailbox, email.subject, body]
      end

      if digest_emails.size > 0
        generate_previews(digest_emails) if configs.use_preview

        log.info("Sending daily digest with #{digest_emails.size} entries..")

        send_digest(digest_emails)
      end

      log.info("Process finished")
    end

    def send_digest(digest_emails)
      digest              = gmail.message
      digest.to           = account.email
      digest.subject      = "[#{aib_domain}] Bacon Mail for #{date}"
      digest.content_type = "text/html"
      digest.body         = email_template(digest_emails)
      digest.deliver!
    end

    def log
      @log ||= Logger.new(STDOUT)
    end

    def aib_domain
      account.username.split("@")[1]
    end

    def gmail
      @gmail ||= Gmail.new(account.username, account.password)
    end

    def digest?(email)
      email.subject.match("Daily Digest for")
    rescue
      nil
    end

    def from_me?(email)
      from = email.from[0]
      "#{from['mailbox']}@#{from['host']}" == account.username
    end

    def get_mailbox_name(email)
      email[:to][0].mailbox.downcase
    rescue "unknown"
    end

    def emails
      gmail.mailbox('[Gmail]/All Mail').emails(on: date)
    end

    def email_template(new_messages)
        # we all know, inline styles sucks. sadly, it's the
        # only way to get them into gmail.
        response = ""
        response += "<h1 style='margin-left: 40px; color: #DC6582;'>Bacon Mail for #{date}</h1>"
        response += "<h3 style='color: #F59FAC; margin-left: 40px; margin-top: -10px; margin-bottom: 30px;'>for <a href='http://#{aib_domain}' style='color: #F59FAC;'>#{aib_domain}</a></h3>"
        response += "<ul style='width: 90%;'>"

        new_messages.sort_by(&:first).each do |m|
          response += "<li style='margin-bottom: 10px; list-style: none; color: #DC6582; border-bottom: 1px dotted #ccc; padding-bottom: 10px; font-weight: bold;'>"
          response += m[0]
          response += ": <strong style='color: #000000; font-weight: normal;'>"

          if configs.use_preview
            response += "<a href='http://#{configs.bucket}.s3.amazonaws.com/"
            response += digest_email_address.gsub("@", "_").gsub(".", "_")
            response += "_"
            response += ::Digest::SHA1.hexdigest(m[1])
            response += ".html' style='color: #000;'>#{m[1]}</a>"
          else
            response += m[1]
          end

          response += "</li>"
        end

        response += "</ul>"
        return response
    end

    def digest_email_address
      account.username
    end

    def date
      Date.today - 1
    end

    def generate_previews(new_messages)
      log.info("Generating previews...")

      AWS::S3::Base.establish_connection!(
        access_key_id:     configs.aws_key,
        secret_access_key: configs.aws_secret
      )

      # set file prefix. useful when we have more than one
      # baconmail account running in the same script instance
      prefix   = digest_email_address.gsub("@", "_").gsub(".", "_")

      # cleanup the bucket
      while (AWS::S3::Bucket.objects(configs.bucket, prefix: prefix).size > 0) do
        AWS::S3::Bucket.objects(configs.bucket).each do |file|
          file.delete if file.key.match(prefix)
        end
      end

      new_messages.sort_by(&:first).each do |m|
        filename = ::Digest::SHA1.hexdigest(m[1])
        AWS::S3::S3Object.store("#{prefix}_#{filename}.html", m[2].to_s, configs.bucket, access: :public_read)
      end
    end
  end
end
