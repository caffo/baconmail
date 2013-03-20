# encoding: UTF-8
module Baconmail
  class Settings
    include Singleton
  
    attr_reader :accounts, :config
  
    def initialize
      settings = YAML::load(File.open("#{ENV['HOME']}/.baconmail"))
      @accounts = settings["accounts"].map{ |account| Account.new(account["username"], account["password"], account["email"]) }
      @config = Config.new(settings["config"]["use_preview"], settings["config"]["bucket"], settings["config"]["aws_key"], settings["config"]["aws_secret"])
    end
  end
end