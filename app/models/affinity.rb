# Following recommendation from http://stackoverflow.com/a/9405812/2333689
class Affinity < ActiveRecord::Base
  belongs_to :persona
  belongs_to :element
  validates_presence_of :effect

  delegate :name, to: :element

  # Gets a pretty HTML and colored representation of this affinity. TODO do this in a presenter.
  def present
    color = case effect
      when 'Absorbs', 'Reflects', 'Block'
        'limegreen'
      when 'Weak'
        'red'
      when 'Resists'
        'royalblue'
      else
        Rails.logger.warn "Unrecognized affinity effect #{effect}, defaulting to black color"
        'black'
    end
    "<b style='color:#{color}'>#{effect}</b>"
  end

  def to_s
    "#{persona.name}'s affinity to #{name}: #{effect}"
  end
end