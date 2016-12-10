class PersonaController < ApplicationController
  def show
    @persona = Persona.find(params[:id])
  end
end