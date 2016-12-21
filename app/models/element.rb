class Element < ApplicationRecord
  validates_presence_of :name

  # has_many :persona_affinities
  # has_many :personas, through: :persona_affinities
end
