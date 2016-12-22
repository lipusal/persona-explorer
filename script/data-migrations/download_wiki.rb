#!bin/rails runner

# This class loops through all downloaded Personas and downloads their source page, saving them in <project root>/wiki

require_relative '../../config/environment'
require 'open-uri'

Persona.all.each do |persona|
  path = File.join File.dirname(__FILE__), '../', '../', 'wiki', "#{persona.name}.html"
  puts "Downloading #{persona.name}, #{persona.source} => #{path}"
  website = open persona.source
  file = File.open path, 'w'
  IO.copy_stream website, file
end