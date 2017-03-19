class Persona < ApplicationRecord
  belongs_to :arcana
  has_many :skills, :class_name => 'PersonaSkill'
  has_many :affinities
  has_many :stats, :class_name => 'PersonaStat'

  def weaknesses
    @weaknesses ||= affinities.select { |a| a.effect =~ /Weak/ }
  end

  def strengths
    @strengths ||= affinities - weaknesses
  end

  def to_s
    "#{name} (##{level})"
  end

  def self.strong_against(*elements)
    Persona.joins(:affinities).where('element_id IN (?) AND effect != ?', elements.map {|e| e.id}.join(','), 'Weak')
  end

  def self.weak_against(*elements)
    Persona.joins(:affinities).where('element_id IN (?) AND effect = ?', elements.map {|e| e.id}.join(','), 'Weak')
  end
end
