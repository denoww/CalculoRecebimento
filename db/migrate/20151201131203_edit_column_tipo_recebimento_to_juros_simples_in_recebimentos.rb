class EditColumnTipoRecebimentoToJurosSimplesInRecebimentos < ActiveRecord::Migration
  def up
    rename_column :recebimentos, :tipo_recebimento, :juros_simples
  end

  def down
    rename_column :recebimentos, :juros_simples, :tipo_recebimento
  end
end
