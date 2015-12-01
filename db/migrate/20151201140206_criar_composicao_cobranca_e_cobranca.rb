class CriarComposicaoCobrancaECobranca < ActiveRecord::Migration
  def up
    Cobranca.create(valor: 95, juros: 0.03, multa: 2, atualizado: 0, vencimento: "2015-10-12")
    ComposicaoCobranca.create(titulo: "Taxa de Condomínio", valor: 15, cobranca_id: 1)
    ComposicaoCobranca.create(titulo: "Salão de festas", valor: 80, cobranca_id: 1)
  end

  def down
    Cobranca.destroy_all
    ComposicaoCobranca.destroy_all
  end
end
