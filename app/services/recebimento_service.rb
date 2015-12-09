class RecebimentoService

  def self.calcular(params)
    cobranca = Cobranca.where(id: params[:cobranca_id]).first
    data_pagamento, valor = params.values_at(:data, :valor)
    pagamentoMaior = juros_atual = multa_atual = min_data_error = diferenca_data = 0
    valor                 ||= 0
    data_pagamento        = data_pagamento.try(:to_date)
    vencimento            = cobranca.vencimento
    ultimo_recebimento    = cobranca.recebimentos.last
    juros_simples         = ConfigCobranca.last.juros_simples

    if cobranca.recebimentos.any?
      vencimento          = ultimo_recebimento.data if ultimo_recebimento.data > vencimento
      juros_atual         = ultimo_recebimento.juros_atual
      multa_atual         = ultimo_recebimento.multa_atual
      if data_pagamento && vencimento > data_pagamento
        if ultimo_recebimento.data > cobranca.vencimento
          return [:min_date, {min_date: "Data não pode ser menor que do ultimo recebimento depois da data de vencimento"}]
        end
      end
    end

    diferenca_data = data_pagamento - vencimento if data_pagamento

    valor_base = calcular_valor_base(
      {juros_atual: juros_atual, multa_atual: multa_atual, juros_simples: juros_simples},
      cobranca
    )

    juros = calcular_juros(
      {juros: params[:juros], valor_base: valor_base, diferenca_data: diferenca_data, juros_atual: juros_atual},
      cobranca
    )

    multa = calcular_multa(
      {multa: params[:multa], valor_base: valor_base, diferenca_data: diferenca_data, multa_atual: multa_atual},
      cobranca
    )

    divida_cobranca = calcular_dCobranca(
      {juros: params[:juros], valor_base: valor_base, juros: juros, multa: multa, valor: valor},
      diferenca_data, cobranca
    )

    objAtual = jurosMultaAtual(
      {juros: juros, multa: multa, valor: valor, divida_cobranca: divida_cobranca}
    )
    juros_atual, multa_atual = objAtual.values_at(:juros_atual, :multa_atual)

    pagamentoMaior = divida_cobranca if divida_cobranca < 0
    divida_cobranca = (divida_cobranca - pagamentoMaior)

    response = {
      data: data_pagamento,
      juros: juros.round(2),
      multa: multa.round(2),
      divida_cobranca: divida_cobranca.round(2),
      pagamentoMaior: pagamentoMaior.round(2),
      juros_atual: juros_atual.round(2),
      multa_atual: multa_atual.round(2),
      valor_base: valor_base.round(2),
      juros_simples: juros_simples
    }

    return [:success, response]
  end

  private

  def self.calcular_valor_base(params, cobranca)
    dividaCobranca = cobranca.divida
    valor_base = dividaCobranca > cobranca.valor ? cobranca.valor : dividaCobranca
    valor_base += params[:juros_atual] + params[:multa_atual] unless params[:juros_simples]
    valor_base
  end

  def self.jurosMultaAtual(obj)
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

  def self.calcular_juros(obj, cobranca)
    if obj[:diferenca_data] > 0
      juros = obj[:valor_base] * (cobranca.juros/100) * obj[:diferenca_data]
      juros += obj[:juros_atual]
    end
    obj[:juros] || juros || 0
  end

  def self.calcular_multa(obj, cobranca)
    if obj[:diferenca_data] > 0
      multa = obj[:valor_base] * (cobranca.multa/100) unless Cobranca.multa_cobrada?
      multa = obj[:multa_atual] if obj[:multa_atual] > 0
    end
    obj[:multa] || multa || 0
  end

  def self.calcular_dCobranca(obj, dData, cobranca)
    composicao_devedora = obj[:valor_base] > cobranca.valor ? cobranca.valor : obj[:valor_base]
    return composicao_devedora + obj[:juros] + obj[:multa] - obj[:valor] if dData > 0 || obj[:juros] != nil
    cobranca.divida - obj[:valor]
  end

end
