# encoding: UTF-8
class Recebimento < ActiveRecord::Base
  validates :valor, :data, :cobranca_id, presence: {message: "Não pode ser vazio"}

  belongs_to :config_cobranca
  belongs_to :cobranca

  def to_frontEnd_obj
    {
      id: id,
      valor: valor,
      juros: juros,
      multa: multa,
      data: data,
      juros_atual: juros_atual,
      multa_atual: multa_atual,
      valor_base: valor_base,
      cobranca_id: cobranca_id
    }
  end

end
