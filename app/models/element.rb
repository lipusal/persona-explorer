class Element < ApplicationRecord
  validates_presence_of :name

  has_many :persona_elements
  has_many :personas, through: :persona_elements
end
