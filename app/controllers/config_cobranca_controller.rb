# encoding: UTF-8
class ConfigCobrancaController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def update
    configCobranca = ConfigCobranca.last
    if configCobranca.update_attributes(configCobranca_param)
      if configCobranca.save
          render json: configCobranca
      else
        render :: Response.object_erros(configCobranca)
      end
    else
      render ::Response.not_found
    end
  end

  protected

  def configCobranca_param
    if params[:config_cobranca].present?
      params.require(:config_cobranca).permit(:juros_simples)
    else
      {}
    end
  end

end
