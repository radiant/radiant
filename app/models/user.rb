require 'digest/sha1'

class User < ActiveRecord::Base

  self.table_name = 'users'

  attr_accessible :name, :password_confirmation, :locale, :login, :password, :email

  has_many :pages, foreign_key: :created_by_id

  # Default Order
  default_scope { order('name') }

  # Associations
  belongs_to :created_by, class_name: 'User'
  belongs_to :updated_by, class_name: 'User'

  # Validations # TODO: remove unique validation in code
  validates_uniqueness_of :login

  validates :password, length: { minimum: 5, maximum: 40},
                      confirmation: true,
                      allow_blank: true

  validates :name, presence: true,
                   length: { maximum: 100 }

  validates :login, length: { minimum: 3, maximum: 40 }, allow_nil: true

  validates :email, length: { maximum: 255 },
                    format: /\A$|^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  class << self
    def unprotected_attributes
      @unprotected_attributes ||= [:name, :email, :login, :password, :password_confirmation, :locale]
    end

    def unprotected_attributes=(array)
      @unprotected_attributes = array.map{|att| att.to_sym }
    end

    def authenticate(login_or_email, password)
      user = from_access_name(login_or_email)
      user && user.authenticated?(password) && user
    end

    private

    def from_access_name(name)
      table = self.arel_table
      where(
        table[:login].eq(name).or(table[:email].eq(name))
      ).first
    end
  end

  def has_role?(role)
    respond_to?("#{role}?") && send("#{role}?")
  end

  def sha1(phrase)
    Digest::SHA1.hexdigest("--#{salt}--#{phrase}--")
  end

  def authenticated?(password)
    self.password == sha1(password)
  end

  def remember_me
    update_attribute(:session_token, sha1(Time.now + Radiant::Config['session_timeout'].to_i)) unless self.session_token?
  end

  def forget_me
    update_attribute(:session_token, nil)
  end

  private

    before_create :encrypt_password
    def encrypt_password
      self.salt = Digest::SHA1.hexdigest("--#{Time.now}--#{login}--sweet harmonious biscuits--")
      self.password = sha1(password)
    end

    before_update :encrypt_password_unless_empty_or_unchanged
    def encrypt_password_unless_empty_or_unchanged
      if password.blank? && password_changed?
        self.password = password_was
      elsif password_was == self.password
      else
        encrypt_password
      end
    end

end
