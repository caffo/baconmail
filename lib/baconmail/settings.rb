# encoding: UTF-8
module Baconmail
  class Settings
    include Singleton

    BACONMAIL_CONFIG_PATH = "#{ENV['HOME']}/.baconmail"

    attr_reader :accounts, :config, :blacklist
  
    def initialize
      settings = YAML::load(File.open(BACONMAIL_CONFIG_PATH))

      @blacklist = [*settings["blacklist"]]
      @accounts  = settings["accounts"].map{ |account| Account.new(account["username"], account["password"], account["email"]) }
      @config    = Config.new(settings["config"]["use_preview"], settings["config"]["bucket"], settings["config"]["aws_key"], settings["config"]["aws_secret"])
    end
  end
end
