class CriarConfigCobranca < ActiveRecord::Migration
  def up
    ConfigCobranca.create!
  end
  def down
    ConfigCobranca.destroy_all
  end
end
