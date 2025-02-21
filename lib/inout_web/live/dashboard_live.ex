defmodule InoutWeb.DashboardLive do
  use Phoenix.LiveView
  import Phoenix.HTML
  alias Inout.Server
  alias InoutWeb.Router.Helpers, as: Routes

  # Hardcoded list of admin employee IDs
  @admin_ids ["d"]  # Replace with actual Admin employee IDs

  def mount(params, session, socket) do
    employee_id = Map.get(session, "user_id") || Map.get(params, "user_id")

    cond do
      connected?(socket) && employee_id in @admin_ids ->
        {:ok, load_dashboard_data(socket, employee_id)}

      connected?(socket) && employee_id not in @admin_ids ->
        {:ok,
         socket
         |> assign(:employee_id, nil)
         |> assign(:error, "Unauthorized access. Admins only.")}

      true ->
        {:ok,
         socket
         |> assign(:employee_id, nil)
         |> assign(:error, "Unauthorized access. Please log in.")}
    end
  end

  defp load_dashboard_data(socket, employee_id) do
    teams = Server.get_teams_with_users()

    assign(socket,
      employee_id: employee_id,
      teams: teams || [],
      error: nil
    )
  end

  def render(assigns) do
    ~H"""
    <div class="flex h-screen bg-gray-100">
      <aside class="w-64 bg-white shadow-md">
        <div class="p-6 text-2xl font-bold text-purple-600">Admin Panel</div>
        <nav class="mt-6">
          <ul>
            <li class="px-4 py-2 hover:bg-gray-200 cursor-pointer">
              Overview
            </li>
            <li class="px-4 py-2 hover:bg-gray-200 cursor-pointer">
              Manage Teams
            </li>
            <li class="px-4 py-2 hover:bg-gray-200 cursor-pointer">
              Manage Employees
            </li>
            <li class="px-4 py-2 hover:bg-gray-200 cursor-pointer">
              Reports
            </li>
            <li class="px-4 py-2 hover:bg-gray-200 cursor-pointer">
              Settings
            </li>
          </ul>
        </nav>
      </aside>

      <div class="flex-1 flex flex-col">
        <main class="p-6 overflow-y-auto">
          <%= if @error do %>
            <p class="text-red-500 text-center font-semibold"><%= @error %></p>
          <% else %>
            <div class="bg-white p-6 rounded-lg shadow-md">
              <h2 class="text-xl font-bold text-gray-800">Welcome, Admin (<%= @employee_id %>)!</h2>

              <h3 class="text-lg font-semibold text-gray-700 mt-6">Manage Teams</h3>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <%= for team <- @teams do %>
                  <div class="p-4 bg-white border border-gray-300 rounded-lg shadow-sm">
                    <h4 class="text-lg font-bold text-gray-800"><%= team.name %></h4>
                    <p class="text-gray-600"><%= team.description || "No description provided" %></p>

                    <h5 class="mt-4 font-semibold text-gray-700">Team Members:</h5>
                    <ul class="space-y-2">
                      <%= for user <- Enum.take(team.users, 3) do %>
                        <li class="p-2 bg-gray-50 rounded-lg shadow-sm">
                          <%= user.employee_id %>
                        </li>
                      <% end %>

                      <%= if length(team.users) > 3 do %>
                        <li>
                          <%= live_patch "View More...", to: Routes.live_path(@socket, InoutWeb.TeamManagementLive, team.id), class: "text-blue-500 cursor-pointer" %>
                        </li>
                      <% end %>

                      <%= if Enum.empty?(team.users) do %>
                        <li class="p-2 bg-gray-50 rounded-lg text-gray-500">
                          No members in this team.
                        </li>
                      <% end %>
                    </ul>
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>
        </main>
      </div>
    </div>
    """
  end
end
