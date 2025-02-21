defmodule InoutWeb.TeamManagementLive do
  use Phoenix.LiveView
  alias Inout.{Repo, Team, User}

  @impl true
  def mount(%{"id" => team_id}, _session, socket) do
    team = Repo.get(Team, team_id) |> Repo.preload(:users)

    if team do
      {:ok,
       assign(socket,
         team: team,
         users: team.users,
         changeset: Team.changeset(team, %{})
       )}
    else
      {:halt, socket |> put_flash(:error, "Team not found.") |> push_redirect(to: "/dashboard")}
    end
  end

  @impl true
  def handle_event("update_team", %{"team" => team_params}, socket) do
    team = socket.assigns.team

    case Repo.update(Team.changeset(team, team_params)) do
      {:ok, updated_team} ->
        {:noreply,
         socket
         |> assign(:team, updated_team)
         |> put_flash(:info, "Team updated successfully.")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:changeset, changeset)
         |> put_flash(:error, "Failed to update team.")}
    end
  end

  @impl true
  def handle_event("remove_user", %{"user_id" => user_id}, socket) do
    with user when not is_nil(user) <- Repo.get(User, user_id),
         {:ok, _user} <- Repo.update(User.changeset(user, %{team_id: nil})) do
      updated_users = Enum.reject(socket.assigns.users, fn u -> u.id == user.id end)
      {:noreply,
       socket
       |> assign(:users, updated_users)
       |> put_flash(:info, "User removed from the team.")}
    else
      nil -> {:noreply, put_flash(socket, :error, "User not found.")}
      {:error, _changeset} -> {:noreply, put_flash(socket, :error, "Failed to remove user.")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6 bg-gray-100 min-h-screen">
      <h1 class="text-2xl font-bold mb-4">Manage Team: <%= @team.name %></h1>

      <!-- Flash Messages -->
      <%= for {type, msg} <- @flash do %>
        <div class={[
          "p-2 mb-4 rounded-lg",
          flash_class(type)
        ]}>
          <%= msg %>
        </div>
      <% end %>

      <!-- Team Details Form -->
      <div class="bg-white p-4 rounded-lg shadow-md mb-6">
        <h2 class="text-lg font-semibold">Team Details</h2>
        <form phx-submit="update_team">
          <div class="mt-2">
            <label class="block text-sm font-medium">Team Name</label>
            <input type="text" name="team[name]" value="<%= @team.name %>"
                   class="w-full p-2 border rounded-lg" />
          </div>

          <div class="mt-2">
            <label class="block text-sm font-medium">Description</label>
            <textarea name="team[description]" class="w-full p-2 border rounded-lg"><%= @team.description %></textarea>
          </div>

          <button type="submit"
                  class="mt-4 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
            Update Team
          </button>
        </form>
      </div>

      <!-- Team Members List -->
      <div class="bg-white p-4 rounded-lg shadow-md">
        <h2 class="text-lg font-semibold mb-4">Team Members</h2>

        <%= if Enum.empty?(@users) do %>
          <p class="text-gray-500">No users in this team.</p>
        <% else %>
          <ul class="space-y-2">
            <%= for user <- @users do %>
              <li class="flex justify-between items-center bg-gray-50 p-2 rounded-lg">
                <span><%= user.employee_id %></span>
                <button phx-click="remove_user" phx-value-user_id="<%= user.id %>"
                        class="bg-red-500 text-white px-2 py-1 rounded hover:bg-red-600">
                  Remove
                </button>
              </li>
            <% end %>
          </ul>
        <% end %>
      </div>
    </div>
    """
  end

  # Helper function for flash message styling
  defp flash_class(:info), do: "bg-blue-100 text-blue-800"
  defp flash_class(:error), do: "bg-red-100 text-red-800"
  defp flash_class(_), do: "bg-gray-100 text-gray-800"
end
