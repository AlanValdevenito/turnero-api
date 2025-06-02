Sequel.migration do
  up do
    create_table(:medicos) do
      primary_key :id
      String :email
      String :nombre
      String :apellido
      String :matricula
      Integer :especialidad_id
      Date :created_on
      Date :updated_on
    end
  end

  down do
    drop_table(:medicos)
  end
end
