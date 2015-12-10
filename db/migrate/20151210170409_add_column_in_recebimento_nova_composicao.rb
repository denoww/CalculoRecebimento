class AddColumnInRecebimentoNovaComposicao < ActiveRecord::Migration
  def change
    add_column :recebimentos, :nova_composicao, :decimal, precision: 14, scale: 2
  end
end
