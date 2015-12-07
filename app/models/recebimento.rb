# encoding: UTF-8
class Recebimento < ActiveRecord::Base
  validates :valor, :data, :cobranca_id, presence: {message: "Não pode ser vazio"}

  belongs_to :config_cobranca
  belongs_to :cobranca

  scope :somente_juros_simples, lambda { where(juros_simples: true) }
  scope :ultimos_criados, lambda { order("created_at desc") }

  def self.ultimo
    ultimos_criados.first
  end

  def self.ultimo_juros_simples
    somente_juros_simples.ultimos_criados.first
  end

  def to_frontEnd_obj
    {
      id: id,
      valor: valor,
      juros: juros,
      multa: multa,
      data: data,
      juros_simples: juros_simples,
      juros_atual: juros_atual,
      multa_atual: multa_atual,
      valor_base: valor_base,
      cobranca_id: cobranca_id
    }
  end

end
