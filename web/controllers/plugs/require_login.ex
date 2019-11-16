# Plug to make routes require login(Never Used but create becuse I thought I was gonna use )
defmodule Checkin.Plugs.RequireLogin do
  import Plug.Conn
  import Phoenix.Controller

  alias Checkin.Router.Helpers

  def init(_params) do
  end

  def call(conn, _params) do
    if conn.assigns[:employee] do #if coonn.asssigns has employee pass conn through
      conn
    else # If not stop moving to that route and flash erorr
      conn
      |> put_flash(:error, "You must be logged in.")
      |> redirect(to: Helpers.employee_path(conn, :index))
      |> halt()
    end
  end

end
