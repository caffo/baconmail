defmodule Baconmail.Inbox do
  require Logger

  def process_inbox!(account) do
    IO.puts("Account: #{account[:username]}")

    Enum.each(emails(account[:username]), fn message ->
      IO.puts("===")
      IO.inspect(message)
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
    {:ok, _pid} =
      Gmail.User.start_mail(
        email_address,
        Application.fetch_env!(:gmail, :refresh_token)
      )

    {:ok, messages} = Gmail.User.messages(email_address, %{})
    messages
  end
end
