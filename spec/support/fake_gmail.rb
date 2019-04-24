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
      subject: "Hi there",
      from: "admin@example.com",
      html_part: nil,
      body: Mail::Body.new,
      :[] => [ double(host: nil, mailbox: "INBOX") ]
    )
  end
end
