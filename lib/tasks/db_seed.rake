# encoding: UTF-8

desc "Load the seed data from SamfundetAuth's db/seeds.rb"
namespace :samfundet_auth_engine do
  namespace :db do
    task :seed => :environment do
      if Rake::Task.task_defined? 'samfundet_domain_engine:db:seed'
        Rake::Task['samfundet_domain_engine:db:seed'].invoke
      else
        raise "SamfundetAuth depends upon SamfundetDomain. Have you forgotten to include it in your Gemfile?"
      end

      print "Deleting existing members and roles, and proceeding with creating new ones.. "

      tasks = []

      [MembersRole, Member, Role].each do |model|
        tasks << Proc.new do
          model.delete_all
        end
      end

      Group.all.each do |group|
        tasks << Proc.new do
          group_leader = Role.find_or_create_by_title(
              :title => group.group_leader_role.to_s,
              :name => "Gjengsjef",
              :description => "Rolle for gjengsjef for #{group.name}.",
              :group => group
          )
        end

        tasks << Proc.new do
          Role.find_or_create_by_title(
              :title => group.short_name.parameterize,
              :name => group.name,
              :description => "Rolle for alle medlemmer av #{group.name}.",
              :group => group,
              :role => Role.find_by_title(group.group_leader_role.to_s)
          )
        end
      end

      # Just to make sure the variable will exist in this scope.
      lim_web_role = Role.new

      tasks << Proc.new do
        lim_web_role = Role.create!(
            :title => "lim_web",
            :name => "Superuser",
            :description => "Superrolle for alle i MG::Web."
        )
      end

      members = [
          { :fornavn => "Sondre",     :etternavn => "Basma",      :mail => "sondre1504@gmail.com"        },
          { :fornavn => "Andreas",    :etternavn => "Hammar",     :mail => "ahammar@gmail.com"           },
          { :fornavn => "Torstein",   :etternavn => "Nicolaysen", :mail => "tnicolaysen@gmail.com"       },
          { :fornavn => "Stig",       :etternavn => "Hornang",    :mail => "hornang@stud.ntnu.no"        },
          { :fornavn => "Erik",       :etternavn => "Smistad",    :mail => "smistad@samfundet.no"        },
          { :fornavn => "Olav",       :etternavn => "Bjørkøy",    :mail => "olav@bjorkoy.com"            },
          { :fornavn => "Jonas",      :etternavn => "Amundsen",   :mail => "JonasBA@Gmail.com"           },
          { :fornavn => "Jonas",      :etternavn => "Myrlund",    :mail => "myrlund@gmail.com"           },
          { :fornavn => "Stian",      :etternavn => "Møllersen",  :mail => "themorn@gmail.com"           },
          { :fornavn => "Håkon",      :etternavn => "Sandsmark",  :mail => "hsandsmark@gmail.com"        },
          { :fornavn => "Lorents",    :etternavn => "Gravås",     :mail => "lorentso@stud.ntnu.no"       },
          { :fornavn => "Anders",     :etternavn => "Eldhuset",   :mail => "anders.w.eldhuset@gmail.com" },
          { :fornavn => "Aleksander", :etternavn => "Burkow",     :mail => "aleksanderburkow@gmail.com"  },
          { :fornavn => "Rune",       :etternavn => "Holmgren",   :mail => "Raane.Holm@gmail.com"        },
          { :fornavn => "Morten",     :etternavn => "Lysgaard",   :mail => "morten@lysgaard.no"          },
          { :fornavn => "Dagrun",     :etternavn => "Haugland",   :mail => "dagrunh@gmail.com"           },
          { :fornavn => "Christoffer",:etternavn => "Tønnessen",  :mail => "chrto@samfundet.no"          },
          { :fornavn => "Trygve",     :etternavn => "Bærland",    :mail => "trygve.baerland@gmail.com"   },
          { :fornavn => "Odd",        :etternavn => "Trondrud",   :mail => "odd@gmali.com"               },
          { :fornavn => "Asbjørn",    :etternavn => "Steinskog",  :mail => "asbjorn@steinskog.me"        },
          { :fornavn => "Simon",      :etternavn => "Randby",     :mail => "simon@samfundet.no"          },
          { :fornavn => "Alf",        :etternavn => "Jonassen",   :mail => "alf1337@gmail.com"           },
          { :fornavn => "Glenn",      :etternavn => "Aarøen",     :mail => "glaar90@gmail.com"           },
          { :fornavn => "Katrine",    :etternavn => "Jordheim",   :mail => "katrine@samfundet.no"        },
          { :fornavn => "Simon",      :etternavn => "Kvannli",    :mail => "simonkvannli@gmail.com"      },
          { :fornavn => "Filip",      :etternavn => "Egge",       :mail => "filip.egge@gmail.com"        },
          { :fornavn => "Stian",      :etternavn => "Steinbakken",:mail => "stiansteinbakken17@gmail.com"},
          { :fornavn => "Anders",      :etternavn => "Sørby",     :mail => "user8715@gmail.com"          },
          { :fornavn => "Erlend",      :etternavn => "Ekern",     :mail => "erlendekern@gmail.com"       },
      ]

      members.each do |member|
        tasks << Proc.new do
          Member.create! member.merge({:passord => "passord", :telefon => "22222222"})
        end
      end

      members.each do |member|
        tasks << Proc.new do
          Member.find_by_mail(member[:mail]).roles << lim_web_role
        end
      end

      print "00%"

      tasks.each_with_index do |task, index|
        task.call
        print "\b\b\b%02d\%" % (100 * (index.to_f + 1) / tasks.length.to_f)
      end

      print "\n"
    end
  end
end
