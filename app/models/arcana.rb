class Arcana < ApplicationRecord
  attr_reader :name
  has_many :personas
end
