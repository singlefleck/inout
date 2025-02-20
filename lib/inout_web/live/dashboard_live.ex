defmodule InoutWeb.DashboardLive do
  use Phoenix.LiveView
  alias Inout.Server
  def mount(params, session, socket) do
    # Fetch from session or fallback to query params
    employee_id = Map.get(session, "user_id") || Map.get(params, "user_id")

    IO.inspect(connected?(socket), label: "Connected")
    IO.inspect(session, label: "Session")
    IO.inspect(params, label: "Params")

    if connected?(socket) && employee_id do
      {:ok, load_dashboard_data(socket, employee_id)}
    else
      {:ok,
       socket
       |> assign(:employee_id, nil)
       |> assign(:error, "Unauthorized access. Please log in.")}
    end
  end


  defp load_dashboard_data(socket, employee_id) do
    attendance_logs = Server.get_attendance(employee_id)
    last_logins = Server.get_last_logins(employee_id, 10)
    expected_login_time = Server.get_expected_login_time(employee_id)
    total_leaves = Server.get_total_leaves(employee_id)
    used_leaves = Server.get_used_leaves(employee_id)
    upcoming_leaves = Server.get_upcoming_leaves(employee_id)
    applied_leaves = Server.get_applied_leaves(employee_id)
    hours_worked_today = Server.get_hours_worked_today(employee_id)
    avg_login_time = Server.get_avg_login_time(employee_id)

    assign(socket,
      employee_id: employee_id,
      attendance_logs: attendance_logs,
      last_logins: last_logins,
      expected_login_time: expected_login_time,
      total_leaves: total_leaves,
      used_leaves: used_leaves,
      upcoming_leaves: upcoming_leaves,
      applied_leaves: applied_leaves,
      hours_worked_today: hours_worked_today,
      avg_login_time: avg_login_time,
      error: nil
    )
  end

  def render(assigns) do
    ~H"""
    <div class="dashboard-container">
      <%= if @error do %>
        <p class="error"><%= @error %></p>
      <% else %>
        <h1>Welcome, <%= @employee_id %>!</h1>

        <h2>Attendance Overview</h2>
        <p>Expected Login Time: <%= @expected_login_time %></p>
        <p>Hours Worked Today: <%= @hours_worked_today %> hours</p>
        <p>Average Login Time (Last 7 days): <%= @avg_login_time %></p>

        <h3>Last 10 Logins</h3>
        <ul>
          <%= for log <- @last_logins do %>
            <li>Login: <%= log.login %> | Logout: <%= log.logout || "Active" %></li>
          <% end %>
        </ul>

        <h3>Attendance Logs</h3>
        <ul>
          <%= for log <- @attendance_logs do %>
            <li>Login: <%= log[:login] %> | Logout: <%= log[:logout] || "N/A" %></li>
          <% end %>
        </ul>

        <h2>Leaves</h2>
        <p>Total Leaves: <%= @total_leaves %></p>
        <p>Used Leaves: <%= @used_leaves %></p>

        <h3>Upcoming Leaves</h3>
        <ul>
          <%= for leave <- @upcoming_leaves do %>
            <li><%= leave.date %></li>
          <% end %>
        </ul>

        <h3>Applied Leaves</h3>
        <ul>
          <%= for leave <- @applied_leaves do %>
            <li><%= leave.date %> - <%= leave.status %></li>
          <% end %>
        </ul>
      <% end %>
    </div>
    """
  end
end
