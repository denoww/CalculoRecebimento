class EditTypeTipoRecebimentoInRecebimentos < ActiveRecord::Migration
  def up
    change_column :recebimentos, :tipo_recebimento, :boolean
  end
  def down
    change_column :recebimentos, :tipo_recebimento, :string
  end
end
