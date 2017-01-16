class Persona < ApplicationRecord
  belongs_to :arcana
  has_many :skills, :class_name => 'PersonaSkill'
  has_many :affinities
  has_many :stats, :class_name => 'PersonaStat'

  def weaknesses
    affinities.select { |a| a.effect =~ /Weak/ }
  end

  def strengths
    affinities - weaknesses
  end

  def to_s
    "#{name} (##{level})"
  end

  def self.strong_against(element)
    Persona.joins(:affinities).where('element_id = ? AND effect != ?', element.id, 'Weak')
  end

  def self.weak_against(element)
    Persona.joins(:affinities).where('element_id = ? AND effect = ?', element.id, 'Weak')
  end
end
