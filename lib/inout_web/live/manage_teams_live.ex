defmodule InoutWeb.ManageTeamsLive do
  use Phoenix.LiveView, layout: {InoutWeb.SideLayout, :live}
  alias Inout.{Repo, Team}

  @impl true
  def mount(_params, _session, socket) do
    teams = Repo.all(Team)
    {:ok, assign(socket, teams: teams)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6 bg-gray-100 min-h-screen">
      <h1 class="text-2xl font-bold mb-4">Manage Teams</h1>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <%= for team <- @teams do %>
          <div class="p-4 bg-white border border-gray-300 rounded-lg shadow-md">
            <h3 class="text-lg font-bold"><%= team.name %></h3>
            <p class="text-gray-600"><%= team.description || "No description available." %></p>

            <.link patch={"/teams/#{team.id}"} class="text-blue-500 mt-2 inline-block">
              View Team
            </.link>
          </div>
        <% end %>
      </div>

      <%= if Enum.empty?(@teams) do %>
        <p class="text-gray-500 mt-6">No teams found.</p>
      <% end %>
    </div>
    """
  end
end
