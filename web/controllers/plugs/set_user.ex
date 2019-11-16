# This adds all information on seesion to assigns so can be acsessed easier
defmodule Checkin.Plugs.SetUser do
  import Plug.Conn

  alias Checkin.Repo
  alias Checkin.Employee

  def init(_params) do

  end

  def call(conn, _params) do
    employee_id = get_session(conn, :employee_id)
    checked_in = get_session(conn, :checked_in)


    cond do
      employee = employee_id && Repo.get(Employee, employee_id) ->
        conn = assign(conn, :employee, employee)
        if checked_in do
          assign(conn, :checked_in, true)
        else
          assign(conn, :checked_in, false)
        end
      true ->
        conn = assign(conn, :employee, nil)
        if checked_in do
          assign(conn, :checked_in, true)
        else
          assign(conn, :checked_in, false)
        end
    end



  end


end
