class CreateKeywordPost < ActiveRecord::Migration
  def change
    create_table :keyword_post do |t|
      t.string :title_occurrence
      t.string :body_occurrence
      t.references :keyword
      t.references :post
      t.timestamps
    end
  end
end
