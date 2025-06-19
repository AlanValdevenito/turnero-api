Sequel.migration do
  up do
    set_column_type :usuarios, :telegram_id, 'BIGINT'
  end

  down do
    set_column_type :usuarios, :telegram_id, 'INTEGER'
  end
end
