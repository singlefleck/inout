defmodule InoutWeb.ManageEmployeesLive do
  use Phoenix.LiveView, layout: {InoutWeb.SideLayout, :live}
  alias Inout.{Repo, User}

  @impl true
  def mount(_params, _session, socket) do
    users = Repo.all(User)
    {:ok, assign(socket, users: users)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6 bg-gray-100 min-h-screen">
      <h1 class="text-2xl font-bold mb-4">Manage Employees</h1>

      <div class="bg-white p-4 rounded-lg shadow-md">
        <h2 class="text-lg font-semibold mb-4">Employee List</h2>

        <%= if Enum.empty?(@users) do %>
          <p class="text-gray-500">No employees found.</p>
        <% else %>
          <ul class="space-y-2">
            <%= for user <- @users do %>
              <li class="p-2 bg-gray-50 rounded-lg shadow-sm">
                <%= user.employee_id %>
              </li>
            <% end %>
          </ul>
        <% end %>
      </div>
    </div>
    """
  end
end
