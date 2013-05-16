class AddTopLevelDomainToFeedsTable < ActiveRecord::Migration
  def change
    add_column :feeds, :top_level_domain, :string
  end
end
