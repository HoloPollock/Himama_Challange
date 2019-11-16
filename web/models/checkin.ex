defmodule Checkin.Check do
  use Checkin.Web, :model

  schema "checkin" do
    field :check_in, :utc_datetime
    field :check_out, :utc_datetime
    belongs_to :employee, Checkin.Employee
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:check_in, :check_out])
    |> validate_required([:check_in])

  end

end
