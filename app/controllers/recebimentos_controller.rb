# encoding: UTF-8
class RecebimentosController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def create
    recebimento = Recebimento.new(recebimento_param)
    recebimento.juros_simples = ConfigCobranca.last.juros_simples
    cobranca = recebimento.cobranca
    if validar_data_recebimento
      if cobranca
        if recebimento.save
          divida = cobranca.divida
          divida = params[:divida_cobranca] if params[:divida_cobranca]
          render json: {
            recebimento: recebimento,
            divida_cobranca: divida,
            totais: cobranca.getTotais
          }
        else
          render ::Response.object_erros(recebimento)
        end
      else
        render ::Response.not_found
      end
    else
      render ::Response.nao_pode_receber
    end
  end

  def destroy
    recebimento = Recebimento.where(id: params[:id]).first
    if recebimento
      if recebimento.destroy
        render json: {
          recebimento: recebimento,
          divida_cobranca: recebimento.cobranca.divida,
          totais: recebimento.cobranca.getTotais
        }
      else
        render ::Response.object_erros(recebimento)
      end
    else
      render ::Response.not_found
    end
  end

  def calcular_divida
    status, response = RecebimentoService.calcular params
    case status
    when :success
      render json: response
    when :min_date
      render json: {errors: response}, status: :bad_request
    end
  end

  protected

  def validar_data_recebimento
    if Recebimento.any?
      return false if Recebimento.last.data > params[:data].to_date
    end
    true
  end

  def recebimento_param
    if params[:recebimento].present?
      params.require(:recebimento).permit(
        :valor, :juros, :multa, :data, :valor_base, :juros_atual,
        :multa_atual, :cobranca_id, :juros_simples
      )
    else
      {}
    end
  end

end
