class PersonasController < ApplicationController

  def index
    # @arcanas = Arcana.all
    @personas = Persona.all
    # @grouped_personas = @personas.group_by &:arcana
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
end