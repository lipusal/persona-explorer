require 'nokogiri'
require 'open-uri'

class WikiParser
  BASE_URL = 'http://megamitensei.wikia.com'.freeze
  PERSONA_3_LIST_URL = "#{BASE_URL}/wiki/List_of_Persona_3_Personas".freeze

  # Initializes a new parser. If online, all data will be fetched from the wiki. Otherwise, data will be fetched from
  # locally-downloaded pages (which must exist, see download_wiki.rb for this)
  def initialize(online = false)
    @online = online
  end

  # Gets all Persona 3 FES arcanas.
  def get_p3_arcanas
    page = Nokogiri::HTML(open(get_persona_list_uri))
    page.css('.mw-headline a').map {|arcana| arcana.text}
  end

  # Gets all personas grouped by arcana
  def get_p3_personas
    # Thanks to http://ruby.bastardsbook.com/chapters/html-parsing/

    page = Nokogiri::HTML(open(get_persona_list_uri))
    arcanas = page.css('.mw-headline a').map {|arcana| arcana.text}   # Duplicated code - but avoids making 2 requests to the same page
    grouped_personas = Hash.new { |hash, key| hash[key] = Array.new }

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
          grouped_personas[arcana] << data
        elsif cell.name == 'td'
          data = grouped_personas[arcana].last
          data[:name] = cell.text.chomp  #Some names have a trailing \n, chomp discards it
          data[:source] = WikiParser::BASE_URL + cell.child[:href]
        else
          raise "Unknown element: #{cell}"
        end
      end
    end

    grouped_personas.each_value do |arcana|
      arcana.each do |persona|
        uri = get_persona_uri(persona)
        puts "Analyzing #{persona[:name]} from #{uri} ..."
        persona.merge!(get_detailed_info open(uri))
      end
    end

    grouped_personas
  end

  # Gets detailed info about a persona, given its wiki page's HTML (which may be obtained online or from a local copy)
  # Obtains stats, resistances, etc.
  def get_detailed_info(html)
    result = {}
    page = Nokogiri::HTML(html)
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

  def get_persona_list_uri
    @online ? PERSONA_3_LIST_URL : File.join(File.dirname(__FILE__), '..', '..', 'wiki', 'List_of_Persona_3_Personas.html')
  end

  def get_persona_uri(persona)
    @online ? persona.source : File.join(File.dirname(__FILE__), '..', '..', 'wiki', 'P3', "#{persona[:name]}.html")
  end

  def extract_table_info(table)
    subtables = table.css '.customtable'
    return if subtables.nil?
    data = {}
    # Stats and resistances are always tables 0 and 1
    data[:stats] = extract_stats (subtables[0])
    data[:resistances] = extract_affinities(subtables[1])
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

  def extract_affinities(table)
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
# require_relative '../../config/environment.rb'
# p = WikiParser.new
# pp(p.get_p3_personas)