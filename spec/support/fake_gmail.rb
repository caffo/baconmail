class FakeGmail
  include RSpec::Mocks::ExampleMethods

  def mailbox(*args)
    double(:mailbox, emails: emails, count: 1)
  end

  def labels(*args)
    double(:labels, new: nil)
  end

  def emails(*args)
    @emails ||= [build_email]
  end

  def build_email
    double(
      :email,
      label: nil,
      unread!: nil,
      archive!: nil,
      :[] => [ double(host: nil, mailbox: "INBOX") ]
    )
  end
end
