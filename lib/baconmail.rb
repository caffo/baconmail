# encoding: UTF-8
require 'rubygems'
require 'gmail'
require 'logger'
require 'date'
require 'digest/sha1'
require 'aws/s3'

class Baconmail < Object
  def self.process_inbox!(email_address, password, target_email)
    log = Logger.new(STDOUT)
    log.info("Account: #{email_address}")
    Gmail.new(email_address, password) do |gmail|
      gmail.inbox.emails(:unread).each do |email|
        mailbox = email[:to].detect{|mail| mail.host == email_address.split("@").last}.mailbox.downcase rescue "unknown"
        gmail.labels.new(mailbox)
        if gmail.mailbox(mailbox).count == 0
          log.info("First email for [#{gmail.mailbox(mailbox)}], forwarding..")
          fwd                 = gmail.message
          fwd.to              = target_email
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

  def self.daily_digest(email_address, password, target_email, configs)
    log         = Logger.new(STDOUT)
    emails      = []
    aib_domain  = email_address.split("@")[1]

    log.info("Account: #{email_address}")

    Gmail.new(email_address, password) do |gmail|
      gmail.mailbox('[Gmail]/All Mail').emails(:on => (Date.today - 1)).each do |email|
       
        next if email.subject.match("Daily Digest for") rescue nil
        next if "#{email.from[0]['mailbox']}@#{email.from[0]['host']}" == email_address
        
        mailbox = email[:to][0].mailbox.downcase rescue "unknown"
        body    = email.html_part.nil? ? email.body : email.html_part.body
        emails << [mailbox, email.subject, body]
      end

      if emails.size > 0
            if configs["use_preview"]
              log.info("Generating previews...")
              self.generate_previews(emails, configs, email_address)
            end

            log.info("Sending daily digest with #{emails.size} entries..")
            digest                 = gmail.message
            digest.to              = target_email
            digest.subject         = "[#{aib_domain}] Daily Digest for #{(Date.today - 1)}"
            digest.content_type    = "text/html"
            digest.body            = self.email_template(emails, aib_domain, configs, email_address)
            digest.deliver!
      end
    end
    log.info("Process finished")
  end

  def self.email_template(new_messages, account, configs, email_address)
      # we all know, inline styles sucks. sadly, it's the
      # only way to get them into gmail.
      response = ""
      response += "<h1 style='margin-left: 40px; color: #000000;'>Daily Digest for #{(Date.today - 1)}</h1>"
      response += "<h3 style='color: #aaaaaa; margin-left: 40px; margin-top: -10px; margin-bottom: 30px;'>for #{account}</h3>"
      response += "<ul style='width: 90%;'>"

      new_messages.sort_by{|x| x[0]}.each do |m|
        response += "<li style='margin-bottom: 10px; list-style: none; color: #3485ae; border-bottom: 1px dotted #ccc; padding-bottom: 10px; font-weight: bold;'>"
        response += m[0]
        response += ": <strong style='color: #000000; font-weight: normal;'>"

        if configs["use_preview"]
          response += "<a href='http://"
          response += configs["bucket"]
          response += ".s3.amazonaws.com/"
          response += email_address.gsub("@", "_").gsub(".", "_")
          response += "_"
          response += Digest::SHA1.hexdigest(m[1])
          response += ".html'>#{m[1]}</a>"
        else
          response += m[1]
        end

        response += "</strong> </li>"
      end

      response += "</ul>"
      return response
  end

  def self.generate_previews(new_messages, configs, email_address)
      AWS::S3::Base.establish_connection!(
        :access_key_id     => configs["aws_key"],
        :secret_access_key => configs["aws_secret"]
      )

      # set file prefix. useful when we have more than one
      # baconmail account running in the same script instance
      prefix   = email_address.gsub("@", "_").gsub(".", "_")
      
      #binding.pry
      
      # cleanup the bucket
      while (AWS::S3::Bucket.objects(configs["bucket"], :prefix => prefix).size > 0) do
        AWS::S3::Bucket.objects(configs["bucket"]).each do |file|
            file.delete if file.key.match(prefix)
        end
      end
      
      new_messages.sort_by{|x| x[0]}.each do |m|
        filename = Digest::SHA1.hexdigest(m[1])
        AWS::S3::S3Object.store("#{prefix}_#{filename}.html", m[2].to_s, configs["bucket"], :access => :public_read)
      end
  end
end
