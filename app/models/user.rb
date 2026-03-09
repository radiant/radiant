class User < ActiveRecord::Base
  has_secure_password

  has_many :pages, foreign_key: :created_by_id

  # Default Order
  default_scope { order(:name) }

  # Associations
  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :updated_by, class_name: "User", optional: true

  # Validations
  validates :login, presence: true, uniqueness: true, length: { within: 3..40 }
  validates :name, presence: true, length: { maximum: 100 }
  validates :email, allow_nil: true, length: { maximum: 255 },
    format: { with: /\A\z|\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :password, length: { within: 5..72 }, if: :password_required?

  class << self
    def unprotected_attributes
      @unprotected_attributes ||= [:name, :email, :login, :password, :password_confirmation, :locale]
    end

    def unprotected_attributes=(array)
      @unprotected_attributes = array.map { |att| att.to_sym }
    end
  end

  def has_role?(role)
    respond_to?("#{role}?") && send("#{role}?")
  end

  def self.authenticate(login_or_email, password)
    user = where("login = ? OR email = ?", login_or_email, login_or_email).first
    user&.authenticate(password) || nil
  end

  private

  def password_required?
    new_record? || password.present?
  end
end
