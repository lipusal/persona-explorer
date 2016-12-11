require 'nokogiri'
require 'singleton'
require 'open-uri'

class WikiParser
  include Singleton

  BASE_URL = 'http://megamitensei.wikia.com'.freeze
  PERSONA_3_LIST_URL = "#{BASE_URL}/wiki/List_of_Persona_3_Personas".freeze

  # Gets all Persona 3 FES arcanas.
  def get_p3_arcanas
    page = Nokogiri::HTML(open(WikiParser::PERSONA_3_LIST_URL))
    page.css('.mw-headline a').map {|arcana| arcana.text}
  end

  # Gets all personas grouped by arcana
  def get_personas
    # Thanks to http://ruby.bastardsbook.com/chapters/html-parsing/

    page = Nokogiri::HTML(open(WikiParser::PERSONA_3_LIST_URL))
    arcanas = page.css('.mw-headline a').map {|arcana| arcana.text}   # Duplicated code - but avoids making 2 requests to the same page
    personas = Hash.new { |hash, key| hash[key] = Array.new }

    page.css('table.table.p3').each_with_index do |table, index|
      arcana = arcanas[index]
      # Skip the first row (1-indexed, not 0-indexed, hence +2), loop through both th's (base level indicators) and
      # td's (persona names)
      table.css('tr:nth-child(n+2) th, tr:nth-child(n+2) td').each do |cell|
        if cell.name == 'th'
          data = {level: cell.text.to_i}
          if cell.child.name == 'abbr'
            data[:other] = cell.child[:title]
          end
          personas[arcana] << data
        elsif cell.name == 'td'
          data = personas[arcana].last
          data[:name] = cell.text.chomp  #Some names have a trailing \n, chomp discards it
          data[:source] = WikiParser::BASE_URL + cell.child[:href]
        else
          raise "Unknown element: #{cell}"
        end
      end
    end

    personas.each_value do |persona_group|
      persona_group.each do |persona|
        puts "Analyzing #{persona[:name]} from #{persona[:source]} ..."
        persona.merge!(get_detailed_info persona[:source])
      end
    end

    personas
  end

  # Gets detailed info about a persona, given its wiki URL. Obtains stats, resistances, etc.
  def get_detailed_info(url)
    result = {}
    page = Nokogiri::HTML(open(url))
    # No easy identifiers, so get where the section starts, where the next section starts, and look at all tables in between
    # TODO: Use XPath to use less code
    start_elem = page.css('span.mw-headline[id^="Persona_3"]').last
    elem = start_elem.parent.next
    until elem.name == 'h3' || elem.name == 'h2' || elem.nil?  # Reached next game, next section or EOF
      if elem.name == 'table'
        result = extract_table_info elem
      elsif elem.name == 'div' && elem[:class] =~ /tabber/
        elem.css('.tabbertab > table').each do |table|
          result.merge!(extract_table_info table)
        end
      end

      elem = elem.next
    end

    result
  end

  private


  def extract_table_info(table)
    subtables = table.css '.customtable'
    return if subtables.nil?
    data = {}
    # Stats and resistances are always tables 0 and 1
    data[:stats] = extract_stats (subtables[0])
    data[:resistances] = extract_resistances(subtables[1])
    # Not all following sections are necessarily present, so use an index
    index = 2
    unless (subtables[2].css('a[title="Skill Card"]') + subtables[2].css('a[title="Heart Item"]')).empty?
      items_table = subtables[2]
      index += 1
      # Ignored
    end
    data[:skills] = extract_skills(subtables[index])
    data[:fusion_spells] = extract_fusion_spells(subtables[index+1]) if subtables.length > index+1

    data
  end

  def extract_stats(table)
    stats = {}
    table.css('tr:first-child > td tr').each do |row|
      stat_name = row.css('td:nth-child(1)').text.chomp
      stat_value = row.css('td:nth-child(2)').text.to_i
      stats[stat_name.to_sym] = stat_value
    end

    stats
  end

  def extract_resistances(table)
    data = {}
    headers = table.css('tr:nth-child(1) th')
    values = table.css('tr:nth-child(2) td')
    (0...headers.length).each do |i|
      h = headers[i].text.chomp.to_sym
      v = values[i].text.chomp
      if v == '-'
        v = nil
      else
        v = v.gsub('n/a', 'Not Applicable').split(/[,&\/]/).map(&:strip)
      end
      data[h] = v
    end

    data
  end

  def extract_skills(table)
    data = {}
    table.css('tr:nth-child(n+3)').each do |row|
      skill = row.css('th').text.chomp
      cost = row.css('td')[0].text.chomp  # TODO: Some of these have notes, see (who?) for example
      effect = row.css('td')[1].text.chomp
      level = row.css('td')[2].text.to_i
      level = nil if level == 0
      data[skill.to_sym] = {cost: cost, effect: effect, level: level}
    end

    data
  end

  def extract_fusion_spells(table)
    data = {}
    table.css('tr:nth-child(n+3)').each do |row|
      skill = row.css('th').text.chomp
      cost = row.css('td')[0].text.chomp  # TODO: Some of these have notes, see (http://megamitensei.wikia.com/wiki/Pyro_Jack) for example
      effect = row.css('td')[1].text.chomp
      prerequisite = row.css('td')[2].text.chomp
      data[skill.to_sym] = {cost: cost, effect: effect, prerequisite: prerequisite}
    end

    data
  end
end

# require 'pp'
# personas = WikiParser.instance.get_personas
# puts "Analyzed personas in #{personas.size} arcanas:"
# pp personas
# pp WikiParser.instance.get_detailed_info 'http://megamitensei.wikia.com/wiki/Pyro_Jack'
# 'http://megamitensei.wikia.com/wiki/Black_Frost'
