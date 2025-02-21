defmodule InoutWeb.SideLayout do
  use Phoenix.Component

  # The live layout wrapper
  def live(assigns) do
    ~H"""
    <div class="flex h-screen bg-gray-100">
      <!-- Sidebar -->
      <aside class="w-64 bg-white shadow-md">
        <div class="p-6 text-2xl font-bold text-purple-600">InOut</div>
        <nav class="mt-6">
          <ul>
            <li class="px-4 py-2 hover:bg-gray-200 cursor-pointer">
              <.link patch="/dashboard" class="block">Overview</.link>
            </li>
            <li class="px-4 py-2 hover:bg-gray-200 cursor-pointer">
              <.link patch="/manage_teams" class="block">Manage Teams</.link>
            </li>
            <li class="px-4 py-2 hover:bg-gray-200 cursor-pointer">
              <.link patch="/manage_employees" class="block">Manage Employees</.link>
            </li>
            <li class="px-4 py-2 hover:bg-gray-200 cursor-pointer">
              <.link patch="/reports" class="block">Reports</.link>
            </li>
            <li class="px-4 py-2 hover:bg-gray-200 cursor-pointer">
              <.link patch="/settings" class="block">Settings</.link>
            </li>
          </ul>
        </nav>
      </aside>

      <!-- Main Content -->
      <main class="flex-1 p-6 overflow-y-auto">
        <%= @inner_content %>
      </main>
    </div>
    """
  end
end
