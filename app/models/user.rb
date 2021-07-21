
class User < ApplicationRecord

  validates :user_name, :session_token, :password_digest, presence: true
  validates :password, length: { minimum: 6, allow_nil: true }
  validates :user_name, :session_token, uniqueness: true
  after_initialize :ensure_session_token

  attr_reader :password

  has_many :cats

  has_many :rental_requests,
    class_name: 'CatRentalRequest',
    foreign_key: :user_id,
    primary_key: :id

  def self.find_by_credentials(user_name, password)
    user = User.find_by(user_name: user_name)
    return user if user && BCrypt::Password.new(user.password_digest).is_password?(password)
    nil
  end

  def self.generate_session_token
    SecureRandom::urlsafe_base64(16)
  end

  def reset_session_token!
    self.session_token = User.generate_session_token
    self.save!
    self.session_token
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def is_password?(pass)
    self.password_digest == BCrypt::Password.new(pass) ? true : false
  end

  def owns_cat?(cat)
    self.cats.include?(cat)
  end

  private
  def ensure_session_token
    self.session_token ||= User.generate_session_token
  end

end