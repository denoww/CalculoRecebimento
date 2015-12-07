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
    #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
    #                                                       #
    # Anotações sobre algumas regras                        #
    #                                                       #
    # Linha 98 ~ 115 (juros atual diferente do anterior     #
    #                   Simples / Composto):                #
    #                                                       #
    # 1 => caso ele seja composto, deve apenas atualizar o  #
    #    o valor base somando a multa e juros do            #
    #    recebimento anterior.                              #
    #                                                       #
    # 2 => se o atual for simples, deve calcular para saber #
    #    qual é o juros e multa que não foram pagas pelo    #
    #    composto, juntamente o valor base de calculo.      #
    #                                                       #
    # Linha 138 ~ 147 (atualizar valor base, juros e multa  #
    #                     para o próximo recebimento):      #
    #                                                       #
    # 1 => no caso de ser simples, deve calcular os juros e #
    #    multa atuais tomando os devidos cuidados de não    #
    #    permitir juros sobre juros e multa sobre multa.    #
    #                                                       #
    # 1.1 => valor base tambem deve se ter atenção, pois    #
    #     pois nele evitamos tambem recebimentos de juros   #
    #     sobre juros, multa sobre multa.                   #
    #                                                       #
    # 2 => no caso de composto, devemos apenar zerar os     #
    #   juros e multas atuais, e atribuir o msm valor da    #
    #   da divida como valor base.                          #
    #                                                       #
    #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

    cobranca = Cobranca.where(id: params[:cobranca_id]).first
    data, valor = params.values_at(:data, :valor)
    pagamentoMaior = juros_atual = multa_atual = min_data_error = diferenca_data = 0
    valor                 ||= 0
    data                  = data.try(:to_date)
    valor_base            = cobranca.valor
    data_calculo          = min_data = cobranca.vencimento
    ultimo_recebimento    = cobranca.recebimentos.last
    juros_simples         = ConfigCobranca.last.juros_simples

    if cobranca.recebimentos.any?
      data_calculo        = ultimo_recebimento.data
      valor_base          = ultimo_recebimento.valor_base

      trocou_tipo_juros = juros_simples != ultimo_recebimento.juros_simples
      if trocou_tipo_juros
        valor_base += ultimo_recebimento.juros_atual
        valor_base += ultimo_recebimento.multa_atual
        if juros_simples
          totais = cobranca.getTotais
          if (totais[:jurosMulta]) > totais[:recebimentos]
            multa_atual = totais[:multa] - (totais[:recebimentos] - totais[:juros])
            if totais[:juros] > totais[:recebimentos]
              juros_atual = totais[:juros] - totais[:recebimentos]
              multa_atual = totais[:multa]
            end
          end
          valor_base = cobranca.valor
          valor_base = cobranca.divida if totais[:recebimentos] > totais[:jurosMulta]
        end
      elsif juros_simples
        juros_atual       = ultimo_recebimento.juros_atual
        multa_atual       = ultimo_recebimento.multa_atual
      end
      if data && data_calculo > data
        min_data_error    = -1
        min_data          = data_calculo
      end
    end

    diferenca_data        = data - data_calculo if data

    juros = calcular_juros(
      {valor_base: valor_base, diferenca_data: diferenca_data, juros_atual: juros_atual},
      cobranca
    )

    multa = calcular_multa(
      {valor_base: valor_base, diferenca_data: diferenca_data, multa_atual: multa_atual},
      cobranca
    )

    divida_cobranca = calcular_dCobranca(
      {valor_base: valor_base, juros: juros, multa: multa, valor: valor},
      diferenca_data, cobranca
    )

    if juros_simples
      encargoAtual = jurosMultaAtual(
        {juros: juros, multa: multa, valor: valor, divida_cobranca: divida_cobranca}
      )
      valor_base = divida_cobranca unless (juros+multa) > valor
    else
      valor_base = divida_cobranca
      encargoAtual = {}
      encargoAtual[:juros_atual] = encargoAtual[:multa_atual] = 0
    end

    pagamentoMaior = divida_cobranca if divida_cobranca < 0
    divida_cobranca = (divida_cobranca - pagamentoMaior)

    render json: {
      juros: juros.round(2),
      multa: multa.round(2),
      min_data_error: min_data_error,
      min_data: min_data,
      divida_cobranca: divida_cobranca.round(2),
      pagamentoMaior: pagamentoMaior.round(2),
      juros_atual: encargoAtual[:juros_atual].round(2),
      multa_atual: encargoAtual[:multa_atual].round(2),
      valor_base: valor_base.round(2),
      juros_simples: juros_simples
    }
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
    if obj[:diferenca_data] > 0
      juros = obj[:valor_base] * (cobranca.juros/100) * obj[:diferenca_data]
      juros += obj[:juros_atual] if obj[:juros_atual] > 0
    end
    juros || params[:juros] || 0
  end

  def calcular_multa(obj, cobranca)
    if obj[:diferenca_data] > 0
      multa = obj[:valor_base] * (cobranca.multa/100) if cobranca.recebimentos.empty?
      multa = obj[:multa_atual] if obj[:multa_atual] > 0
    end
    multa || params[:multa] || 0
  end

  def calcular_dCobranca(obj, dData, cobranca)
    return obj[:valor_base] + obj[:juros] + obj[:multa] - obj[:valor] if dData > 0
    cobranca.divida - obj[:valor]
  end

end
