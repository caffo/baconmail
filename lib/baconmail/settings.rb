# encoding: UTF-8
module Baconmail
  class Settings
    include Singleton
  
    attr_reader :accounts, :config
  
    def initialize
      settings = YAML::load(File.open("#{ENV['HOME']}/.baconmail"))
      @accounts = settings["accounts"].map{ |account| Account.new(account["username"], account["password"], account["email"]) }
      @config = Config.new(settings["use_preview"], settings["bucket"], settings["aws_key"], settings["aws_secret"])
    end
  end
end