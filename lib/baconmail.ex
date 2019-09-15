defmodule Baconmail.CLI do
  def main(argv) do
    case Enum.at(argv, 0) do
      "process" ->
        Enum.each(accounts(), fn account ->
          Baconmail.Inbox.process_inbox!(account)
        end)

      "digest" ->
        IO.puts("Not yet implemented")

      _ ->
        IO.puts("baconmail [process | digest]")
    end
  end

  def accounts do
    Application.fetch_env!(:baconmail, :accounts)
  end
end
