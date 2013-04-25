class CreatePosts < ActiveRecord::Migration
   def change
    create_table :post do |t|
    	t.string :title
    	t.string :body
      t.timestamps
    end
  end
end
