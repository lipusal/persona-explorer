class Persona < ApplicationRecord
  belongs_to :arcana
  has_many :skills, class_name: 'PersonaSkill'
  has_many :elements, class_name: 'PersonaElement'
end
