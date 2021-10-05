# frozen_string_literal: true

desc "Load the seed data from SamfundetAuth's db/seeds.rb"
namespace :samfundet_auth_engine do
  namespace :db do
    task seed: :environment do
      if Rake::Task.task_defined? 'samfundet_domain_engine:db:seed'
        Rake::Task['samfundet_domain_engine:db:seed'].invoke
      else
        raise 'SamfundetAuth depends upon SamfundetDomain. Have you forgotten to include it in your Gemfile?'
      end

      print 'Deleting existing members and roles, and proceeding with creating new ones.. '

      tasks = []

      [MembersRole, Member, Role].each do |model|
        tasks << proc do
          model.delete_all
        end
      end

      Group.all.each do |group|
        tasks << proc do
          Role.find_or_create_by(title: group.group_leader_role.to_s) do |role|
            role.name = 'Gjensjef'
            role.description = "Rolle for gjengsjef for #{group.name}"
            role.group = group
          end
        end

        tasks << proc do
          Role.find_or_create_by(title: group.short_name.parameterize) do |role|
            role.name = group.name,
                        role.description = "Rolle for alle medlemmer av #{group.name}."
            role.group = group
            role.role = Role.find_by_title(group.group_leader_role.to_s)
          end
        end
      end

      # Just to make sure the variable will exist in this scope.
      lim_web_role = Role.new

      tasks << proc do
        lim_web_role = Role.create!(
          title: 'lim_web',
          name: 'Superuser',
          description: 'Superrolle for alle i MG::Web.'
        )
      end

      members = [
        { fornavn: 'Alf', etternavn: 'Jonassen', mail: 'alf1337@gmail.com' }
      ]

      members.each do |member|
        tasks << proc do
          Member.create! member.merge(passord: 'passord', telefon: '22222222')
        end
      end

      members.each do |member|
        tasks << proc do
          Member.find_by(mail: member[:mail]).roles << lim_web_role
        end
      end

      print '00%'

      tasks.each_with_index do |task, index|
        task.call
        print format("\b\b\b%02d%%", (100 * (index.to_f + 1) / tasks.length.to_f))
      end

      print "\n"
    end
  end
end
