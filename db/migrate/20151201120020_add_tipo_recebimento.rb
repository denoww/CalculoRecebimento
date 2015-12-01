class AddTipoRecebimento < ActiveRecord::Migration
  def change
    add_column :recebimentos, :tipo_recebimento, :string
  end
end
