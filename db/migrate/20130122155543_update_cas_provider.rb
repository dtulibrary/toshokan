class UpdateCasProvider < ActiveRecord::Migration
  def up
    say 'Renaming :cas providers'
    User.where(:provider => :cas).each do |user|
      user.provider = 'dtu_cas'
      user.save
    end
  end

  def down
    say 'Renaming :dtu_cas providers'
    User.where(:provider => :dtu_cas).each do |user|
      user.provider = 'cas'
      user.save
    end
  end
end
