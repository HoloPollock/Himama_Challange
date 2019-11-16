defmodule Checkin.Router do
  use Checkin.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug  Checkin.Plugs.SetUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Checkin do
    pipe_through :browser # Use the default browser stack

    get "/", EmployeeController, :index
    post "/login", EmployeeController, :login
    get "/logout", EmployeeController, :logout


    get "/checkin/new", CheckinController, :new
    post "/checkin", CheckinController, :create
    post "/checkout", CheckinController, :checkout
    get "/clocks", CheckinController, :clock_event
    get "/clockspublic", CheckinController, :clock_event_public
    delete "/clock/:id", CheckinController, :delete
    get "/clock/:id/edit", CheckinController, :edit
    put "/clock/:id", CheckinController, :update
  end

  # Other scopes may use custom stacks.
  # scope "/api", Checkin do
  #   pipe_through :api
  # end
end
