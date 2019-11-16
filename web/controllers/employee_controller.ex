defmodule Checkin.EmployeeController do
  use Checkin.Web, :controller
  alias Checkin.Employee

  def index(conn, _params) do
    changeset = Employee.changeset(%Employee{}, %{})
    render conn, "index.html", changeset: changeset
  end

  #login to system
  def login(conn, %{"employee" => name}) do
    %{"name" => validate} = name
    case validate do #make sure some name was retrived from the form
      "" ->
        changeset = Employee.changeset(%Employee{}, %{})
        IO.inspect changeset
        changeset =  %{changeset | action: :insert}
        render conn, "index.html", changeset: changeset
      _ ->
        changeset = Employee.changeset(%Employee{}, name)
        IO.inspect changeset
        case insert_or_update(changeset) do
          {:ok, employee} ->
            conn
            |> put_flash(:info, "Welcome")
            |> put_session(:employee_id, employee.id)
            |> redirect(to: checkin_path(conn, :new))
          {:error, _reason} ->
            conn
            |> put_flash(:error, "Error signing in")
            |> redirect(to: employee_path(conn, :index))
        end
      end
  end

  #logout from user also checks out if checkin while logged out(This was a design descion and may not have been the best thought but was done for simplity of use)
  def logout(conn, _params) do
    case conn.assigns.checked_in do
      true ->
        case check_out(conn) do
          {:ok, _post} ->
            conn
            |> configure_session(drop: true) #drop all session informatiom
            |> put_flash(:info, "Signed Out")
            |> redirect(to: employee_path(conn, :index))
          {:error, _changeset} ->
            IO.puts "error" ## This means database is down should just error
        end
        false ->
          conn
          |> configure_session(drop: true)
          |> put_flash(:info, "Signed Out")
          |> redirect(to: employee_path(conn, :index))
    end
  end

  defp insert_or_update(changeset) do
    case Repo.get_by(Employee, name: changeset.changes.name) do
      nil ->
        Repo.insert(changeset)
      employee ->
        {:ok, employee}
    end
  end

  #Copy of checkout so when logout happens a checkout event occurs
  defp check_out(conn) do
    id = conn.assigns.employee.id
    query = Repo.all(from e in Checkin.Employee, join: c in assoc(e, :checkin), where: is_nil(c.check_out), where: e.id == ^id, preload: [checkin: c]) ## Surpisingly hard to get by assoc and only one but becuse the way the code work this should only return one so the double head will always work
    [head | _] = query
    temp = head.checkin
    [head | _ ] = temp ## This gives me the the Check Item with a null check_out for the "logged in" employee
    IO.inspect head
    changeset = head
    |> Repo.preload(:employee) ## Preload assocaation so can be updated by Repo
    |> Ecto.Changeset.change(check_out: Timex.now)


    case Repo.update(changeset) do
      {:ok, post} ->
        {:ok, post}
      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
