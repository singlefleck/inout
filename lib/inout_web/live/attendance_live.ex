defmodule InoutWeb.AttendanceLive do
  use Phoenix.LiveView
  alias Inout.Server

  def mount(_params, session, socket) do
    user_id = Map.get(session, "user_id", nil)
    logged_in = !!user_id

    if connected?(socket) && logged_in do
      {:ok,
       assign(socket,
         logged_in: true,
         employee_id: user_id,
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

  ## Registration Event
  def handle_event("register", %{"employee_id" => employee_id, "password" => password}, socket) do
    case Server.register_user(employee_id, password) do
      {:ok, _user} ->
        {:noreply, assign(socket, :registration_error, "Registration successful. Please log in.")}

      {:error, changeset} ->
        {:noreply,
         assign(socket, :registration_error, "Registration failed: #{inspect(changeset.errors)}")}

      _ ->
        {:noreply, assign(socket, :registration_error, "Unexpected error during registration.")}
    end
  end

  ## Login Event
  def handle_event("login", %{"employee_id" => employee_id, "password" => password}, socket) do
    IO.inspect(employee_id, label: "employee_id")

    case Server.authenticate(employee_id, password) do
      {:ok, user} ->
        IO.inspect(user, label: "user")

        {:noreply,
         socket
         |> assign(:logged_in, true)
         |> assign(:employee_id, user.employee_id)
         |> put_flash(:info, "Welcome, #{user.employee_id}!")
         |> push_navigate(to: "/dashboard?user_id=#{user.employee_id}")}

      {:error, reason} ->
        {:noreply, assign(socket, :error, "Login failed: #{reason}")}
    end
  end

  ## Logout Event
  def handle_event("logout", _params, socket) do
    {:noreply,
     socket
     |> assign(:logged_in, false)
     |> assign(:employee_id, nil)
     |> push_navigate(to: "/attendance")}
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
        <h2>Login</h2>
        <%= if @error do %>
          <p class="error"><%= @error %></p>
        <% end %>
        <form phx-submit="login">
          <input type="text" name="employee_id" placeholder="Employee ID" />
          <input type="password" name="password" placeholder="Password" />
          <button type="submit">Login</button>
        </form>

        <h2>Register</h2>
        <%= if @registration_error do %>
          <p class="error"><%= @registration_error %></p>
        <% end %>
        <form phx-submit="register">
          <input type="text" name="employee_id" placeholder="Employee ID" />
          <input type="password" name="password" placeholder="Password" />
          <button type="submit">Register</button>
        </form>
      <% end %>
    </div>
    """
  end
end
