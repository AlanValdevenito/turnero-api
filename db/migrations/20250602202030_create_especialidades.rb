Sequel.migration do
  up do
    create_table(:especialidades) do
      primary_key :id
      String :nombre
      Integer :duracion_de_turnos
      Date :created_on
      Date :updated_on
    end
  end

  down do
    drop_table(:especialidades)
  end
end
