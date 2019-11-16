defmodule Checkin.Employee do
  use Checkin.Web, :model

  schema "employee" do
    field :name, :string
    has_many :checkin, Checkin.Check
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end

end
