# frozen_string_literal: true

require 'active_support/configurable'
require 'samfundet_auth/engine'

module SamfundetAuth
  include ActiveSupport::Configurable

  class << self
    def setup
      yield config

      database_path = "#{Rails.root}/config/database.yml"

      if File.exist? database_path
        database_config = YAML.load_file database_path

        if config.domain_database
          [Role, MembersRole].each do |model|
            model.establish_connection database_config[config.domain_database.to_s]
          end
        end

        if config.member_database
          Member.establish_connection database_config[config.member_database.to_s]
        end

        Member.table_name = config.member_table.to_s if config.member_table
      end
    end
  end
end
