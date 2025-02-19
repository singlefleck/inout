defmodule InoutWeb.AttendanceLive do
  use Phoenix.LiveView

  def mount(_params, session, socket) do
    {:ok, assign(socket, logged_in: false, error: nil, registration_error: nil, employee_id: nil, attendance_logs: %{})}
  end

  # Handle user registration
  def handle_event("register", %{"employee_id" => employee_id, "password" => password}, socket) do
    case Inout.register_user(employee_id, password) do
      :ok ->
        {:noreply, assign(socket, error: nil, registration_error: "Registration successful. Please log in.")}
      {:error, reason} ->
        {:noreply, assign(socket, registration_error: reason)}
    end
  end

  # Handle user login
  def handle_event("login", %{"employee_id" => employee_id, "password" => password}, socket) do
    case Inout.authenticate(employee_id, password) do
      :ok ->
        {:noreply, assign(socket, logged_in: true, employee_id: employee_id, error: nil)}
      {:error, reason} ->
        {:noreply, assign(socket, error: reason)}
    end
  end

  def handle_event("log_in", _params, socket) do
    {:ok, _time} = Inout.log_in(socket.assigns.employee_id)
    {:noreply, update_attendance(socket)}
  end

  def handle_event("log_out", _params, socket) do
    {:ok, _time} = Inout.log_out(socket.assigns.employee_id)
    {:noreply, update_attendance(socket)}
  end

  def handle_event("logout", _params, socket) do
    {:noreply, assign(socket, logged_in: false, employee_id: nil, attendance_logs: %{})}
  end

  defp update_attendance(socket) do
    logs = Inout.get_attendance(socket.assigns.employee_id)
    assign(socket, attendance_logs: Map.put(socket.assigns.attendance_logs, socket.assigns.employee_id, logs))
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Inout Employee Attendance Tracker</h1>

      <%= if @logged_in do %>
        <p>Welcome, <%= @employee_id %>!</p>
        <button phx-click="logout">Logout</button>

        <!-- Log In Attendance -->
        <button phx-click="log_in">Log In</button>
        <button phx-click="log_out">Log Out</button>

        <!-- Attendance Logs -->
        <h2>Attendance Logs</h2>
        <ul>
          <%= for {employee_id, logs} <- @attendance_logs do %>
            <li>
              <strong><%= employee_id %>:</strong>
              <ul>
                <%= for log <- logs do %>
                  <li>
                    Login: <%= log[:login] %>
                    <%= if log[:logout], do: " | Logout: \#{log[:logout]}" %>
                  </li>
                <% end %>
              </ul>
            </li>
          <% end %>
        </ul>
      <% else %>
        <h2>Login</h2>
        <%= if @error do %>
          <p style="color: red;"><%= @error %></p>
        <% end %>
        <form phx-submit="login">
          <input type="text" name="employee_id" placeholder="Employee ID" />
          <input type="password" name="password" placeholder="Password" />
          <button type="submit">Login</button>
        </form>

        <h2>Register</h2>
        <%= if @registration_error do %>
          <p style="color: red;"><%= @registration_error %></p>
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
