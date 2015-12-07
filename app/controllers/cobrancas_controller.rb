# encoding: UTF-8
class CobrancasController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    raise "asd"
    respond_to do |f|
      f.html { render_layout }
      f.json { render json: Cobranca.all.map(&:to_frontEnd_obj) }
    end
  end

  def show
    cobranca = Cobranca.where(id: params[:id]).first
    if cobranca
      render json: cobranca.to_frontEnd_obj
    else
      render ::Response.not_found
    end
  end

end
