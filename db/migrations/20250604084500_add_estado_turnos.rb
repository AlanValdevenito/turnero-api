Sequel.migration do
  up do
    add_column :turnos, :estado, String
  end

  down do
    drop_column :turnos, :estado
  end
end
