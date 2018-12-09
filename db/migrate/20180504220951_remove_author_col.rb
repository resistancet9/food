class RemoveAuthorCol < ActiveRecord::Migration[5.2]
  def change
    remove_column :posts, :author
  end
end
