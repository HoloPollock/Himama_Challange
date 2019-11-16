defmodule Checkin.Repo.Migrations.AddCheckin do
  use Ecto.Migration

  def change do
    create table(:employee) do
      add :name, :string
    end
    create table(:checkin) do
      add :employee_id, references(:employee)
      add :check_in, :datetime
      add :check_out, :datetime
    end

  end
end
