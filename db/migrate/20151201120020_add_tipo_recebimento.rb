class AddTipoRecebimento < ActiveRecord::Migration
  def change
    add_column :recebimentos, :juros_simples, :boolean
  end
end
