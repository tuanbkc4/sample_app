class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token

  before_create :create_activation_digest
  before_save{:email_downcase}

  validates :name, presence: true,
    length: {maximum: Settings.length.name}

  validates :email, presence: true,
    length: {maximum: Settings.length.email},
    format: {with: Settings.regex.email_regex},
    uniqueness: true

  validates :password, presence: true,
    length: {minimum: Settings.length.password},
    allow_nil: true

  has_secure_password

  validate :valid_birthday, if: ->{birthday.present?}

  class << self
    # Returns the hash digest of the given string.
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
  end

  # Forgets a user.
  def forget
    update_attribute :remember_digest, nil
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  private

  def valid_birthday
    return if Date.parse(birthday) > Settings.length.date.years.ago

    errors.add(:birthday, I18n.t("error.valid"))
  end

  def email_downcase
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
