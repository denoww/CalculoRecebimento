# encoding: UTF-8
class Cobranca < ActiveRecord::Base
  has_many :recebimentos
  has_many :composicao_cobrancas

  def to_frontEnd_obj
    return {
      id: id,
      valor: valor,
      juros: juros,
      multa: multa,
      divida_cobranca: divida,
      vencimento: vencimento,
      configCobranca: ConfigCobranca.last,
      totais: getTotais,
      recebimentos: recebimentos.map(&:to_frontEnd_obj),
      composicaoCobranca: composicao_cobrancas.ordem_de_criacao.map(&:to_frontEnd_obj)
    }
  end

  def getTotais
    composicao = composicao_cobrancas.sum(:valor)
    juros = recebimentos.sum(:juros) - recebimentos.sum(:juros_atual)
    juros += recebimentos.last.juros_atual if recebimentos.any?
    multa = recebimentos.any? ? recebimentos.first.multa : 0
    recebimento = recebimentos.sum(:valor)
    pagamentoMaior = composicao + juros + multa - recebimento
    pagamentoMaior = 0 if pagamentoMaior > 0
    return {
      composicao: composicao,
      recebimentos: recebimento,
      jurosMulta: juros + multa,
      juros: juros,
      multa: multa,
      pagamentoMaior: pagamentoMaior.abs
    }
  end

  def divida
    return valor if recebimentos.empty?
    totais = getTotais
    divida_total = (totais[:composicao] + totais[:jurosMulta]) - totais[:recebimentos]
    return divida_total > 0 ? divida_total : 0
  end

end
