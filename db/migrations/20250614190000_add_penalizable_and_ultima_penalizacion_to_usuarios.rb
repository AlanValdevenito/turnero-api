Sequel.migration do
  up do
    add_column :usuarios, :penalizable, TrueClass, default: true
    add_column :usuarios, :ultima_penalizacion, DateTime, null: true
  end

  down do
    drop_column :usuarios, :penalizable
    drop_column :usuarios, :ultima_penalizacion
  end
end
