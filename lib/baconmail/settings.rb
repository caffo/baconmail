# encoding: UTF-8
module Baconmail
  class Settings
    include Singleton

    BACONMAIL_CONFIG_PATH = "#{ENV['HOME']}/.baconmail"

    attr_reader :accounts, :config, :blacklist
  
    def initialize
      settings = YAML::load(File.open(BACONMAIL_CONFIG_PATH))
      configs = settings["config"]

      @blacklist = [*settings["blacklist"]]
      @accounts  = settings["accounts"].map { |account| Account.new(account["username"], account["email"]) }
      @config    = init_config(settings["config"])
    end

    def init_config(configs)
      Config.new(
        configs["use_preview"],
        configs["bucket"],
        configs["aws_key"],
        configs["aws_secret"],
        configs["google_client_id"],
        configs["google_client_secret"]
      )
    end
  end
end
