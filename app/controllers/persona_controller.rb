class PersonaController < ApplicationController

  def index
    # @arcanas = Arcana.all
    @personas = Persona.all
    # @grouped_personas = @personas.group_by &:arcana
  end

  def show
    @persona = Persona.find(params[:id])
  end
end