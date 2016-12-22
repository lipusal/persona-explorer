class Element < ApplicationRecord
  validates_presence_of :name

  # has_many :persona_affinities
  # has_many :personas, through: :persona_affinities

  #TODO Normalize elements

  def self.basic
    Element.all.reject do |e|
      %w[All Not\ Applicable Recovery Bad\ Status Ailment].include? e.name
    end
  end
end
