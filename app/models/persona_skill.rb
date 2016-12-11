# Following recommendation from http://stackoverflow.com/a/9405812/2333689
class PersonaSkill < ActiveRecord::Base
  belongs_to :persona
  belongs_to :skill

  delegate :name, :effect, to: :skill
end