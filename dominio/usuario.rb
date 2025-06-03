class Usuario
  attr_reader :email, :updated_on, :created_on, :telegram_id
  attr_accessor :id

  def initialize(email, id = nil, telegram_id = nil)
    raise ArgumentError if email.nil? || email.strip.empty?

    @email = email
    @id = id
    @telegram_id = telegram_id
  end
end
