defmodule Baconmail.Inbox do
  require Logger

  def process_inbox!(account) do
    IO.puts("Account: #{account[:username]}")

    Enum.each(emails(account[:email]), fn email ->
      IO.puts("Not yet implemented")
      IO.puts(email)
      # mailbox = find_mailbox_name(email)
      # create_label(mailbox)

      # forward_email(mailbox, email) if first_email?(mailbox)

      # email.label(mailbox)
      # email.unread!
      # email.archive!

      # log.info("\tProcessing #{email[:subject]}")
    end)

    IO.puts("Process finished")
  end

  def emails(email_address) do
    # Gmail.User.threads(email_address)
    ["email 1"]
  end
end
