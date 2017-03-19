require 'hashie'

module PersonaSearchHelper

  def self.search(params)
    result = Persona.order(:name)
    result = level_filter(params, result)
    result = arcana_filter(params, result)
    result = affinities_filter(params, result)
  end

  def self.effects_map
    @map ||= [
        Hashie::Mash.new(effect: 'Weak', string: 'Be weak against'),
        Hashie::Mash.new(effect: 'Resists', string: 'Resist'),
        Hashie::Mash.new(effect: 'Block', string: 'Block'),
        Hashie::Mash.new(effect: 'Reflects', string: 'Reflect'),
        Hashie::Mash.new(effect: 'Absorbs', string: 'Absorb')
    ]
  end

  private

  def self.level_filter(params, result)
    return result unless params[:level_rel].present? && params[:level].present? && %w[> >= = <= <].include?(params[:level_rel])

    result.where("level #{params[:level_rel]} ?", params[:level])
  end

  def self.arcana_filter(params, result)
    return result unless params[:arcana].present?

    result.joins(:arcana).where('arcanas.name IN (?)', params[:arcana])
  end

  def self.affinities_filter(params, result)
    # affinities_rel = use ANDs or ORs; affinity_rel = weak/strong/absorb/etc.; affinity_val = fire/ice/etc. (affinity_* can be repeated, but always in pairs, i.e. the arrays' lengths should be equal)
    return result unless params[:affinities_rel].present? && params[:affinity_rel].present? && params[:affinity_val].present?

    relationship_map = Hashie::Mash.new('and': 'INTERSECT', 'or': 'UNION')
    relationship = relationship_map[params[:affinities_rel].try(:downcase)] || 'UNION'
    return result if relationship.nil?

    affinity_rels, affinity_vals = params[:affinity_rel], params[:affinity_val]
    return unless affinity_rels.length === affinity_vals.length

    select = 'SELECT personas.id FROM personas JOIN affinities ON affinities.persona_id = personas.id JOIN elements on affinities.element_id = elements.id WHERE '
    sql = select.dup
    (0...affinity_rels.length).each do |i|
      sql << " #{relationship} #{select}" if i > 0
      sql << "elements.name = '#{affinity_vals[i]}' AND affinities.effect = '#{affinity_rels[i]}'"
    end

    ids = Persona.connection.select_all(sql).to_ary.map { |e| e['id'] }
    result.where('personas.id IN (?)', ids)
  end

end