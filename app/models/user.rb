require 'digest/sha1'

class User < ActiveRecord::Base
  
  # Default Order
  default_scope :order => 'name'
  
  # Associations
  belongs_to :created_by, :class_name => 'User'
  belongs_to :updated_by, :class_name => 'User'
  
  # Validations
  validates_uniqueness_of :login
  
  validates_confirmation_of :password, :if => :confirm_password?
  
  validates_presence_of :name, :login
  validates_presence_of :password, :password_confirmation, :if => :new_record?
  
  validates_format_of :email, :allow_nil => true, :with => /^$|^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  
  validates_length_of :name, :maximum => 100, :allow_nil => true
  validates_length_of :login, :within => 3..40, :allow_nil => true
  validates_length_of :password, :within => 5..40, :allow_nil => true, :if => :validate_length_of_password?
  validates_length_of :email, :maximum => 255, :allow_nil => true
  
  validates_numericality_of :id, :only_integer => true, :allow_nil => true
  
  attr_writer :confirm_password
  class << self
    def unprotected_attributes
      @unprotected_attributes ||= [:name, :email, :login, :password, :password_confirmation, :locale]
    end
    
    def unprotected_attributes=(array)
      @unprotected_attributes = array.map{|att| att.to_sym }
    end
  end
  
  def has_role?(role)
    respond_to?("#{role}?") && send("#{role}?")
  end
  
  private
    
    def validate_length_of_password?
      new_record? or not password.to_s.empty?
    end

end
