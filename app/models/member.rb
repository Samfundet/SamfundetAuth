class Member < ActiveRecord::Base
  self.primary_key = :medlem_id

  has_many :members_roles
  has_many :roles, :through => :members_roles

  attr_accessible :fornavn, :etternavn, :mail, :telefon

  validates_presence_of :fornavn, :etternavn, :mail, :telefon, :passord

  if Rails.env == "production"
    establish_connection "mdb2_production"
    set_table_name "lim_medlemsinfo"
  else
    attr_accessible :passord
  end

  def firstname
    fornavn
  end

  def lastname
    etternavn
  end

  def full_name
    "#{firstname} #{lastname}"
  end

  # Return a members roles as an array of symbols (used by dec_auth)
  # This returns an array of symbols representing the roles.
  def role_symbols
    added_roles = (roles || []).map { |r| r.title.to_sym }

    [:medlem] + added_roles
  end

  def role_symbols_with_hierarchy
    Authorization::Engine.instance.roles_with_hierarchy_for self
  end

  def self.authenticate(member_id_or_email, password)
    if Rails.env == "production"
      authenticate_production member_id_or_email, password
    else
      authenticate_development member_id_or_email, password
    end
  end

  private

  def self.authenticate_production(member_id_or_email, password)
    silence do # Prevents passwords from showing up in the logs.
      member_id = connection.select_value sanitize_sql([
                                                           "SELECT * FROM sett_lim_utvidet_medlemsinfo(?, ?)",
                                                           member_id_or_email.to_s,
                                                           password
                                                       ])
      unless member_id.nil?
        Member.find member_id
      end
    end
  end

  def self.authenticate_development(member_id_or_email, password)
    # There are no SQL standard for lower case search,
    # and that's why there's no help from ruby or rails.
    member = Member.find_by_medlem_id(member_id_or_email) ||
        Member.where("lower(mail) = ?", member_id_or_email.downcase).first

    member if member and member.passord == password
  end
end
