# require 'google/api_client/client_secrets'
require 'googleauth/stores/file_token_store'

# encoding: UTF-8
module Baconmail
  class Authorizer
    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
    USER_ID = 'default'
    SCOPE = Google::Apis::GmailV1::AUTH_SCOPE

    class << self
      def call
        raise "Google Client ID or Google Client Secret are invalid." if invalid_keys?

        credentials || fetch_credentials
      end

      def credentials
        authorizer.get_credentials(USER_ID)
      end

      def fetch_credentials
        Baconmail.logger.info "Open the following URL in your browser and authorize the application."
        Baconmail.logger.info authorization_url
        Baconmail.logger.info "Enter the authorization code:"

        code = STDIN.gets.chomp

        authorizer.get_and_store_credentials_from_code(user_id: USER_ID, code: code, base_url: OOB_URI)
      end

      def authorizer
        Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
      end

      def client_id
        Google::Auth::ClientId.new(config.google_client_id, config.google_client_secret)
      end

      def token_store
        Google::Auth::Stores::FileTokenStore.new(file: Baconmail::Settings::BACONMAIL_CONFIG_PATH)
      end

      def authorization_url
        authorizer.get_authorization_url(base_url: OOB_URI)
      end

      def invalid_keys?
        "#{config.google_client_id}".empty? || "#{config.google_client_secret}".empty?
      end

      def config
        Baconmail::Settings.instance.config
      end
    end
  end
end
