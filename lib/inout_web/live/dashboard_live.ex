defmodule InoutWeb.DashboardLive do
  use Phoenix.LiveView
  import Phoenix.HTML
  alias Inout.Server

  def mount(params, session, socket) do
    employee_id = Map.get(session, "user_id") || Map.get(params, "user_id")

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
    members_on_leave_today = Server.get_members_on_leave_today()
    teams = Server.get_teams()

    current_team_id = case teams do
      [first_team | _] -> first_team.id
      [] -> nil
    end

    assign(socket,
      employee_id: employee_id,
      attendance_logs: attendance_logs || [],
      last_logins: last_logins || [],
      expected_login_time: expected_login_time || "N/A",
      total_leaves: total_leaves || 0,
      used_leaves: used_leaves || 0,
      upcoming_leaves: upcoming_leaves || [],
      applied_leaves: applied_leaves || [],
      hours_worked_today: hours_worked_today || 0,
      avg_login_time: avg_login_time || "N/A",
      members_on_leave_today: members_on_leave_today || [],
      teams: teams || [],
      current_team_id: current_team_id,
      error: nil
    )
  end

  def handle_event("change_team", %{"team" => team_id}, socket) do
    updated_data = Server.load_team_data(team_id)

    {:noreply,
     socket
     |> assign(:current_team_id, team_id)
     |> assign(updated_data)}
  end

  def render(assigns) do
    ~H"""
      <div class="flex h-screen bg-gray-100">
        <aside class="w-64 bg-white shadow-md">
          <div class="p-6 text-2xl font-bold text-purple-600">InOut</div>
          <nav class="mt-6">
            <ul>
              <li class="px-4 py-2 hover:bg-gray-200"><a href="#">Overview</a></li>
              <li class="px-4 py-2 hover:bg-gray-200"><a href="#">My Team</a></li>
              <li class="px-4 py-2 hover:bg-gray-200"><a href="#">Manage Employees</a></li>
              <li class="px-4 py-2 hover:bg-gray-200"><a href="#">Reports</a></li>
              <li class="px-4 py-2 hover:bg-gray-200"><a href="#">Settings</a></li>
            </ul>
          </nav>
        </aside>

        <div class="flex-1 flex flex-col">


          <main class="p-6 overflow-y-auto">
            <%= if @error do %>
              <p class="text-red-500 text-center font-semibold"><%= @error %></p>
            <% else %>
              <div class="bg-white p-6 rounded-lg shadow-md">
                <h2 class="text-xl font-bold text-gray-800">Welcome, <%= @employee_id %>!</h2>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-4">
                  <div class="p-4 bg-blue-100 rounded-lg">Expected Login Time: <strong><%= @expected_login_time %></strong></div>
                  <div class="p-4 bg-green-100 rounded-lg">Hours Worked Today: <strong><%= @hours_worked_today %></strong> hours</div>
                  <div class="p-4 bg-yellow-100 rounded-lg col-span-2">Average Login Time (Last 7 days): <strong><%= @avg_login_time %></strong></div>
                </div>

                <h3 class="text-lg font-semibold text-gray-700 mt-6">Members on Leave Today</h3>
                <ul class="space-y-2">
                  <%= for member <- @members_on_leave_today do %>
                    <li class="p-3 bg-red-100 rounded-lg shadow-sm">
                      <%= member.employee_id %> - <%= member.reason %>
                    </li>
                  <% end %>
                  <%= if Enum.empty?(@members_on_leave_today) do %>
                    <li class="p-3 bg-gray-50 rounded-lg shadow-sm text-gray-500">No members are on leave today.</li>
                  <% end %>
                </ul>

                <h3 class="text-lg font-semibold text-gray-700 mt-6">Last 10 Logins</h3>
                <ul class="space-y-2">
                  <%= for log <- @last_logins do %>
                    <li class="p-3 bg-gray-50 rounded-lg shadow-sm">
                      Login: <%= log.login %> | Logout: <%= log.logout || "Active" %>
                    </li>
                  <% end %>
                </ul>

                <h3 class="text-lg font-semibold text-gray-700 mt-6">Attendance Logs</h3>
                <ul class="space-y-2">
                  <%= for log <- @attendance_logs do %>
                    <li class="p-3 bg-gray-50 rounded-lg shadow-sm">
                      Login: <%= log[:login] %> | Logout: <%= log[:logout] || "N/A" %>
                    </li>
                  <% end %>
                </ul>

                <h2 class="text-xl font-semibold text-gray-700 mt-6">Leaves</h2>
                <div class="grid grid-cols-2 gap-4">
                  <div class="p-4 bg-indigo-100 rounded-lg">Total Leaves: <strong><%= Phoenix.HTML.html_escape(@total_leaves) %></strong></div>
                  <div class="p-4 bg-pink-100 rounded-lg">Used Leaves: <strong><%= Phoenix.HTML.html_escape(@used_leaves) %></strong></div>
                </div>

                <h3 class="text-lg font-semibold text-gray-700 mt-6">Upcoming Leaves</h3>
                <ul class="space-y-2">
                  <%= for leave <- @upcoming_leaves do %>
                    <li class="p-3 bg-gray-50 rounded-lg shadow-sm">
                      <%= leave.date %>
                    </li>
                  <% end %>
                </ul>

                <h3 class="text-lg font-semibold text-gray-700 mt-6">Applied Leaves</h3>
                <ul class="space-y-2">
                  <%= for leave <- @applied_leaves do %>
                    <li class="p-3 bg-gray-50 rounded-lg shadow-sm">
                      <%= leave.date %> - <%= leave.status %>
                    </li>
                  <% end %>
                </ul>
              </div>
            <% end %>
          </main>
        </div>
      </div>
    """
  end
end
