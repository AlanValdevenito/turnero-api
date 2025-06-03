Sequel.migration do
  change do
    add_column :usuarios, :telegram_id, Integer, null: true
  end
end
