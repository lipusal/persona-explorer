class PersonasController < ApplicationController

  def index
    @personas = if (search_params = search_params_slice(params)).empty?
        Persona.all
      else
        PersonaSearchHelper.search(search_params)
      end
  end

  def show
    @persona = Persona.find(params[:id])
  end

  def advanced_search
    if params[:affinities].present?
      # TODO: Rails doesn't seem to pick up parameter arrays (sending affinities multiple times just picks up the last one)
      @personas = Persona.strong_against(Element.find_by(name: params[:affinities]))
    end
  end

  private

  def search_params_slice(params)
    params.slice(:level_filter, :level_rel, :level, :arcana_filter, :arcana, :affinities_rel, :affinity_rel, :affinity_val)
  end
end