def create_ability actions, subjects
  ability = Object.new
  ability.extend CanCan::Ability
  ability.can actions, subjects
  ability
end
