Sequel.migration do
  up do
    add_column :especialidades, :limite_turnos_por_usuario, Integer, null: true
  end

  down do
    drop_column :especialidades, :limite_turnos_por_usuario
  end
end
