class Skill < ApplicationRecord
  validates_presence_of :name, :effect

  has_many :persona_skills
  has_many :personas, through: :persona_skills
end
