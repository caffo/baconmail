# encoding: UTF-8
module Baconmail
  class Digest
    def self.daily_digest(account, configs)
      log         = Logger.new(STDOUT)
      emails      = []
      aib_domain  = account.username.split("@")[1]
    
      log.info("Account: #{account.username}")
    
      Gmail.new(account.username, account.password) do |gmail|
        gmail.mailbox('[Gmail]/All Mail').emails(:on => (Date.today - 1)).each do |email|
           
          next if email.subject.match("Daily Digest for") rescue nil
          next if "#{email.from[0]['mailbox']}@#{email.from[0]['host']}" == account.username
            
          mailbox = email[:to][0].mailbox.downcase rescue "unknown"
          body    = email.html_part.nil? ? email.body : email.html_part.body
          emails << [mailbox, email.subject, body]
        end
    
        if emails.size > 0
              if configs.use_preview
                log.info("Generating previews...")
                self.generate_previews(emails, configs, account.username)
              end
    
              log.info("Sending daily digest with #{emails.size} entries..")
              digest                 = gmail.message
              digest.to              = account.email
              digest.subject         = "[#{aib_domain}] Bacon Mail for #{(Date.today - 1)}"
              digest.content_type    = "text/html"
              digest.body            = self.email_template(emails, aib_domain, configs, account.username)
              digest.deliver!
        end
      end
      log.info("Process finished")
    end
    
    def self.email_template(new_messages, account, configs, email_address)
        # we all know, inline styles sucks. sadly, it's the
        # only way to get them into gmail.
        response = ""
        response += "<h1 style='margin-left: 40px; color: #DC6582;'>Bacon Mail for #{(Date.today - 1)}</h1>"
        response += "<h3 style='color: #F59FAC; margin-left: 40px; margin-top: -10px; margin-bottom: 30px;'>for <a href='http://#{account}' style='color: #F59FAC;'>#{account}</a></h3>"
        response += "<ul style='width: 90%;'>"
    
        new_messages.sort_by{|x| x[0]}.each do |m|
          response += "<li style='margin-bottom: 10px; list-style: none; color: #DC6582; border-bottom: 1px dotted #ccc; padding-bottom: 10px; font-weight: bold;'>"
          response += m[0]
          response += ": <strong style='color: #000000; font-weight: normal;'>"
    
          if configs.use_preview
            response += "<a href='http://"
            response += configs.bucket
            response += ".s3.amazonaws.com/"
            response += email_address.gsub("@", "_").gsub(".", "_")
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
    
    def self.generate_previews(new_messages, configs, email_address)
        AWS::S3::Base.establish_connection!(
          :access_key_id     => configs.aws_key,
          :secret_access_key => configs.aws_secret
        )
    
        # set file prefix. useful when we have more than one
        # baconmail account running in the same script instance
        prefix   = email_address.gsub("@", "_").gsub(".", "_")
          
        #binding.pry
          
        # cleanup the bucket
        while (AWS::S3::Bucket.objects(configs.bucket, :prefix => prefix).size > 0) do
          AWS::S3::Bucket.objects(configs.bucket).each do |file|
              file.delete if file.key.match(prefix)
          end
        end
          
        new_messages.sort_by{|x| x[0]}.each do |m|
          filename = ::Digest::SHA1.hexdigest(m[1])
          AWS::S3::S3Object.store("#{prefix}_#{filename}.html", m[2].to_s, configs.bucket, :access => :public_read)
        end
    end
  end
end