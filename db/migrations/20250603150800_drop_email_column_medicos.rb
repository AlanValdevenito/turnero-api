Sequel.migration do
  up do
    alter_table(:medicos) do
      drop_column :email
    end
  end
end
