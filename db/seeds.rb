# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require_relative '../app/helpers/wiki_parser'
require 'set'

puts 'Retrieving Persona 3 data, this will take a while...'

require 'pry'
require 'json'

# Uncomment this to actually query Wiki and write results to JSON file
# File.write(File.join(File.dirname(__FILE__), 'seeds.json'), WikiParser.instance.get_personas.to_json)

data = HashWithIndifferentAccess.new(
  JSON.parse(File.read(File.join(File.dirname(__FILE__), 'seeds.json'))).to_h
)

# Create all arcanas
Arcana.create!(data.keys.map{ |arcana| {name: arcana} }) if Arcana.first.blank?

# Create all resistance/weakness/etc elements
elements = Set.new
data.values.each do |personas|
  personas.each do |persona|
    # TODO do all personas with no resistances inherit from a previous persona?
    next if persona[:resistances].nil?
    persona[:resistances].values.
      reject { |v| v.nil? }.
      each do |element_group|
        if element_group.is_a? Array
          element_group.each { |elem| elements.add elem }
        else
          elements.add element_group
        end
      end
  end
end
Element.create!(elements.map { |elem| {name: elem} }) if Element.first.blank?

# Create all personas and relations
data.each_pair do |arcana, personas|
  personas.each do |persona|
    #TODO create 'other' column
    p = Persona.create!(name: persona[:name], level: persona[:level], source: persona[:source], arcana: Arcana.find_by!(name: arcana))

    # Resistances/weaknesses
    if persona.has_key?(:resistances)
      persona[:resistances].
        #TODO add inheritance field
        reject { |k, v| k == 'Inherit' || v.nil? }.
        each do |effect, elems|
          elems.each do |e|
            p.elements.create!(element: Element.find_by!(name: e), effect: effect)
          end
        end
    end

    # Skills
    persona[:skills].each_pair do |skill_name, attrs|
      skill = Skill.find_or_create_by!(name: skill_name, effect: attrs[:effect])
      p.skills.create! cost: attrs[:cost], level: attrs[:level], skill: skill
    end
  end
end

puts 'Done'