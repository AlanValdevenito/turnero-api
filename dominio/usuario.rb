class Usuario
  attr_reader :email, :updated_on, :created_on, :telegram_id
  attr_accessor :id, :penalizable, :ultima_penalizacion

  def initialize(email, id: nil, telegram_id: nil, penalizable: true, ultima_penalizacion: nil)
    raise ArgumentError if email.nil? || email.strip.empty?

    @email = email
    @id = id
    @telegram_id = telegram_id
    @penalizable = penalizable
    @ultima_penalizacion = ultima_penalizacion
  end
end
