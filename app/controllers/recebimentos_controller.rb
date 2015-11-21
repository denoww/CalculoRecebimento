# encoding: UTF-8
class RecebimentosController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def create
    recebimento = Recebimento.new(recebimento_param)
    cobranca = recebimento.cobranca
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
    cobranca = Cobranca.where(id: params[:cobranca_id]).first
    data, valor = params.values_at(:data, :valor)
    pagamentoMaior = juros_atual = multa_atual = 0
    valor                 ||= 0
    data                  = data.try(:to_date)
    valor_base            = cobranca.valor
    data_calculo          = cobranca.vencimento

    if cobranca.recebimentos.any?
      ultimo_recebimento  = cobranca.recebimentos.last
      juros_atual         = ultimo_recebimento.juros_atual
      multa_atual         = ultimo_recebimento.multa_atual
      valor_base          = ultimo_recebimento.valor_base
      data_calculo        = ultimo_recebimento.data
    end

    diferenca_data        =  data ? (data - data_calculo) : 0

    juros = calcular_juros(
      {valor_base: valor_base, diferenca_data: diferenca_data, juros_atual: juros_atual},
      cobranca
    )

    multa = calcular_multa(
      {valor_base: valor_base, diferenca_data: diferenca_data, multa_atual: multa_atual},
      cobranca
    )

    divida_cobranca = calcular_dCobranca(
      {valor_base: valor_base, juros: juros, multa: multa, valor: valor}
    )

    encargoAtual = jurosMultaAtual(
      {juros: juros, multa: multa, valor: valor, divida_cobranca: divida_cobranca}
    )

    valor_base = divida_cobranca unless (juros+multa) > valor
    pagamentoMaior = divida_cobranca if divida_cobranca < 0
    divida_cobranca = (divida_cobranca - pagamentoMaior)

    render json: {
      juros: juros.round(2),
      multa: multa.round(2),
      divida_cobranca: divida_cobranca.round(2),
      pagamentoMaior: pagamentoMaior.round(2),
      juros_atual: encargoAtual[:juros_atual].round(2),
      multa_atual: encargoAtual[:multa_atual].round(2),
      valor_base: valor_base.round(2)
    }
  end

  protected

  def recebimento_param
    if params[:recebimento].present?
      params.require(:recebimento).permit(:valor, :juros, :multa, :data, :valor_base, :juros_atual, :multa_atual, :cobranca_id)
    else
      {}
    end
  end

  private

  def jurosMultaAtual(obj)
    if (obj[:juros] + obj[:multa]) > obj[:valor]
      multa_atual = obj[:multa] - (obj[:valor] - obj[:juros])
      if obj[:juros] > obj[:valor]
        juros_atual = obj[:juros] - obj[:valor]
        multa_atual = obj[:multa]
      end
    end

    return {
      juros_atual: juros_atual || 0,
      multa_atual: multa_atual || 0
    }
  end

  def calcular_juros(obj, cobranca)
    juros = params[:juros] || 0
    if obj[:diferenca_data] > 0
      juros = obj[:valor_base] * (cobranca.juros/100) * obj[:diferenca_data]
      juros += obj[:juros_atual] if obj[:juros_atual] > 0
    end
    return juros
  end

  def calcular_multa(obj, cobranca)
     if obj[:diferenca_data] > 0
      multa = obj[:valor_base] * (cobranca.multa/100) if cobranca.recebimentos.empty?
      multa = obj[:multa_atual] if obj[:multa_atual] > 0
    end
    return multa || params[:multa] || 0
  end

  def calcular_dCobranca(obj)
    divida_cobranca = obj[:valor_base] + obj[:juros] + obj[:multa] - obj[:valor]
    return divida_cobranca
  end

end
