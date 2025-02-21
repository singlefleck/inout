defmodule InoutWeb.SettingsLive do
  use Phoenix.LiveView, layout: {InoutWeb.SideLayout, :live}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, settings: %{})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6 bg-gray-100 min-h-screen">
      <h1 class="text-2xl font-bold mb-4">Settings</h1>

      <div class="bg-white p-4 rounded-lg shadow-md">
        <p class="text-gray-500">Settings feature is under development.</p>
      </div>
    </div>
    """
  end
end
