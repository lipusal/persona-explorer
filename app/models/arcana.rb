class Arcana < ApplicationRecord
  validates_presence_of :name
  has_many :personas
end
