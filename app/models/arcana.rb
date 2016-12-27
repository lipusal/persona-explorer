class Arcana < ApplicationRecord
  validates_presence_of :name
  has_many :personas

  def to_s
    "#{name} (##{id})"
  end
end
