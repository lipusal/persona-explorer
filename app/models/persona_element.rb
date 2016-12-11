# Following recommendation from http://stackoverflow.com/a/9405812/2333689
class PersonaElement < ActiveRecord::Base
  belongs_to :persona
  belongs_to :element

  delegate :name, to: :element
end