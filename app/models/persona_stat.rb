# Following recommendation from http://stackoverflow.com/a/9405812/2333689
class PersonaStat < ActiveRecord::Base
  belongs_to :persona
  belongs_to :stat
  validates_presence_of :value

  delegate :name, to: :stat
end