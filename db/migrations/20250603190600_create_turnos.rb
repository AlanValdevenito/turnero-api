Sequel.migration do
  up do
    create_table(:turnos) do
      primary_key :id
      foreign_key :medico_id, :medicos
      foreign_key :usuario_id, :usuarios
      DateTime :fecha_hora
      Date :created_on
      Date :updated_on
    end
  end

  down do
    drop_table(:turnos)
  end
end
