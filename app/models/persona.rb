class Persona < ApplicationRecord
  attr_reader :name, :level, :source
  has_one :arcana
end
