defmodule InoutWeb.AttendanceLive do
  use Phoenix.LiveView
  alias Inout.Server
  alias Pow.Plug

  def mount(_params, session, socket) do
    user = Plug.current_user(socket)

    if connected?(socket) && user do
      {:ok,
       assign(socket,
         logged_in: true,
         employee_id: user.employee_id,
         attendance_logs: %{},
         page: :dashboard,
         error: nil,
         registration_error: nil,
         dashboard_data: %{}
       )}
    else
      {:ok,
       assign(socket,
         logged_in: false,
         employee_id: nil,
         attendance_logs: %{},
         page: :login,
         error: nil,
         registration_error: nil,
         dashboard_data: %{}
       )}
    end
  end

  ## Log Attendance
  def handle_event("log_in", _params, socket) do
    {:ok, _time} = Server.log_in(socket.assigns.employee_id)
    {:noreply, update_attendance(socket)}
  end

  def handle_event("log_out", _params, socket) do
    {:ok, _time} = Server.log_out(socket.assigns.employee_id)
    {:noreply, update_attendance(socket)}
  end

  ## Logout Event
  def handle_event("logout", _params, socket) do
    {:noreply,
     socket
     |> assign(:logged_in, false)
     |> assign(:employee_id, nil)
     |> push_navigate(to: "/attendance")}
  end

  ## Update Attendance Logs
  defp update_attendance(socket) do
    logs = Server.get_attendance(socket.assigns.employee_id)

    assign(socket,
      attendance_logs: Map.put(socket.assigns.attendance_logs, socket.assigns.employee_id, logs)
    )
  end

  ## Render Function
  def render(assigns) do
    ~H"""
    <style>
      body {
        font-family: Arial, sans-serif;
        background-color: #f4f4f4;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
        margin: 0;
      }

      .container {
        background-color: #fff;
        padding: 20px;
        border-radius: 8px;
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        width: 400px;
      }

      h1 {
        text-align: center;
        color: #333;
      }

      input[type="text"],
      input[type="password"] {
        width: 100%;
        padding: 10px;
        margin: 10px 0;
        border: 1px solid #ccc;
        border-radius: 4px;
      }

      button {
        width: 100%;
        padding: 10px;
        background-color: #4CAF50;
        color: white;
        border: none;
        border-radius: 4px;
        cursor: pointer;
      }

      button:hover {
        background-color: #45a049;
      }

      .error {
        color: red;
        text-align: center;
      }

      .success {
        color: green;
        text-align: center;
      }

      ul {
        list-style-type: none;
        padding: 0;
      }

      li {
        margin: 5px 0;
      }
    </style>

    <div class="container">
      <h1>Inout Employee Attendance Tracker</h1>

      <%= if @logged_in do %>
        <p>Welcome, <%= @employee_id %>!</p>
        <button phx-click="logout">Logout</button>

        <h2>Attendance</h2>
        <button phx-click="log_in">Log In</button>
        <button phx-click="log_out">Log Out</button>

        <h3>Attendance Logs</h3>
        <ul>
          <%= for {employee_id, logs} <- @attendance_logs do %>
            <li>
              <strong><%= employee_id %>:</strong>
              <ul>
                <%= for log <- logs do %>
                  <li>
                    Login: <%= log[:login] %>
                    <%= if log[:logout], do: " | Logout: #{log[:logout]}" %>
                  </li>
                <% end %>
              </ul>
            </li>
          <% end %>
        </ul>
      <% else %>
      <h2>Please Log In</h2>
      <ul>
        <li class="px-4 py-2 hover:bg-gray-200 cursor-pointer">
          <.link patch={Routes.pow_session_path(@conn, :new)} class="block">Login</.link>
        </li>
        <li class="px-4 py-2 hover:bg-gray-200 cursor-pointer">
          <.link patch={Routes.pow_registration_path(@conn, :new)} class="block">Register</.link>
        </li>
      </ul>

      <% end %>
    </div>
    """
  end
end
