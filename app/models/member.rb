# frozen_string_literal: true

class Member < ActiveRecord::Base
  self.primary_key = :medlem_id

  has_many :members_roles, dependent: :destroy
  has_many :roles, through: :members_roles

  attr_accessor :passord if %w[production staging].include? Rails.env

  validates_presence_of :fornavn, :etternavn, :mail, :telefon

  validates_presence_of :passord if Rails.env.development?

  def firstname
    fornavn
  end

  def lastname
    etternavn
  end

  def full_name
    "#{firstname} #{lastname}"
  end

  def self.authenticate(member_id_or_email, password)
    if %w[production staging].include? Rails.env
      authenticate_production member_id_or_email, password
    else
      authenticate_development member_id_or_email, password
    end
  end

  private

  def self.authenticate_production(member_id_or_email, password)
    Rails.logger.silence do # Prevents passwords from showing up in the logs.
      member_id = connection.select_value sanitize_sql([
                                                         'SELECT * FROM sett_lim_utvidet_medlemsinfo(?, ?)',
                                                         member_id_or_email.to_s,
                                                         password
                                                       ])
      Member.find member_id unless member_id.nil?
    end
  end

  def self.authenticate_development(member_id_or_email, password)
    # There are no SQL standard for lower case search,
    # and that's why there's no help from ruby or rails.
    member = Member.find_by_medlem_id(member_id_or_email) ||
             Member.where('lower(mail) = ?', member_id_or_email.downcase).first

    member if member && (member.passord == password)
  end
end
