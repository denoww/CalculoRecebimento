class CreateConfigCobrancas < ActiveRecord::Migration
  def change
    create_table :config_cobrancas do |t|
      t.boolean :juros_simples, default: true

      t.timestamps null: false
    end

    add_index :config_cobrancas, :juros_simples
  end
end
