# Everything with the name Checkin should have been called Clock didn't have time to fix
# TODO: Change to ClockController
defmodule Checkin.CheckinController do
  use Checkin.Web, :controller
  use Timex

  alias Checkin.Check

  #Go to check in chcek out page
  def new(conn, _param) do
    changeset = Check.changeset(%Check{}, %{})

    render conn, "new.html", changeset: changeset
  end

  #route to checkuser in
  #TODO change name to checkim
  def create(conn, _params) do
    check_in = %{check_in: Timex.now, check_out: nil}

    changeset = conn.assigns.employee #get employee to make associated with chcekin event
    |> build_assoc(:checkin) #build assocation with Employee table
    |> Check.changeset(check_in) #create change set for checkin event

    case Repo.insert(changeset) do
      {:ok, _post} ->
        conn
        |> put_session(:checked_in, true) #add checked in to session
        |> redirect(to: checkin_path(conn, :new))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end

  end

  #route to check user out
  #TODO change way changeset is extrated from database if possible
  def checkout(conn, _params) do
    id = conn.assigns.employee.id
    test = Repo.all(from e in Checkin.Employee, join: c in assoc(e, :checkin), where: is_nil(c.check_out), where: e.id == ^id, preload: [checkin: c])
    [head | _] = test # this is done here do get the stuct out of to list because the way I pulled out of database probobly not the best way
    temp = head.checkin
    [head | _ ] = temp
    IO.inspect head
    changeset = head
    |> Repo.preload(:employee) #load assocaiton with employee for update
    |> Ecto.Changeset.change(check_out: Timex.now)


    case Repo.update(changeset) do #update the clock evert
      {:ok, _post} ->
        conn
        |> put_session(:checked_in, false)
        |> redirect(to: checkin_path(conn, :new))
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end
    # render conn, "new.html", changeset: changeset
  end

  #Get all clock event for a single user
  def clock_event(conn, _param) do
    clocks = Repo.all(Check)
    render conn, "clocks.html", clocks: clocks
  end

  #Get all clock events for all users and there assocaited employee information
  def clock_event_public(conn, _param) do
    clocks = Repo.all(Check)
    |> Repo.preload(:employee)

    render conn, "all.html", clocks: clocks

  end

  #Delete clock event
  def delete(conn, %{"id" => clock_id}) do
    Repo.get(Check,clock_id) |> Repo.delete!

    conn
    |> put_flash(:info, "Topic Deleted")
    |> redirect(to: checkin_path(conn, :clock_event))
  end


  #route to bring to edit page for clock event
  def edit(conn, %{"id" => clock_id}) do
    clock = Repo.get(Check, clock_id)
    changeset = Check.changeset(clock)

    render conn, "edit.html", changeset: changeset, clock: clock
  end

  #Update clock event with new check in and check out informatiomn
  #TODO add validation that check out is after check in
  def update(conn, %{"id" => clock_id, "check" => %{"check_in" => check_in, "check_out" => check_out}}) do
    old_clock = Repo.get(Check, clock_id)
    #convert datetime struct from datetime selector to internal datetime model
    {:ok, new_check_in} = Ecto.DateTime.cast(check_in)
    {:ok, new_check_out} = Ecto.DateTime.cast(check_out)

    new_check = ecto_to_datetime(new_check_in)

    new_check_o = ecto_to_datetime(new_check_out)

    new_check = %{check_in: new_check, check_out: new_check_o}
    changeset = Check.changeset(old_clock, new_check)

    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Clock Updated")
        |> redirect(to: checkin_path(conn, :clock_event))
      {:error, changeset} ->
        IO.inspect changeset
        render conn, "edit.html", changeset: changeset, clock: old_clock

    end

  end

  #convert fom Ecto.Datetime to datetime model for database
  defp ecto_to_datetime(time_event) do
    new_time = time_event
    |>Ecto.DateTime.to_erl
    |>NaiveDateTime.from_erl!
    |>DateTime.from_naive!("Etc/UTC")

    new_time
  end

end
