class EditTypeTipoRecebimentoInRecebimentos < ActiveRecord::Migration
  def change
    change_column :recebimentos, :tipo_recebimento, :boolean
  end
end
