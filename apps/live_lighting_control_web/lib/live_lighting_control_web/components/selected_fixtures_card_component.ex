defmodule LiveLightingControlWeb.SelectedFixturesCardComponent do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS
  alias LiveLightingControl.Utils

  def render(assigns) do
    ~H"""
    <div class="w-full h-full flex flex-col">
      <div class="bg-neutral-700 p-2 rounded-t-lg" phx-click={JS.toggle(to: "#hidden-content-#{@id}")}>
        <h2 class="text-sm font-semibold">Selected fixtures</h2>
      </div>

      <div class="p-4 overflow-x-auto" id={"hidden-content-#{@id}"}>
        <table class="table-auto w-full border-collapse border border-neutral-600">
          <thead>
            <tr class="bg-neutral-800 text-gray-400">
              <th class="border-l-4 p-0 border-neutral-600 w-0"></th>
              <th class="border border-neutral-600 px-4 py-2 text-left w-36">Label</th>
              <th class="border border-neutral-600 px-4 py-2 text-left w-auto">Id</th>
            </tr>
          </thead>

          <tbody>
            <%= for fixture <- LiveLightingControl.Utils.get_selected_fixtures(@fixtures, @selected_fixture_ids) do %>
              <tr class="hover:bg-neutral-700 text-sm">
                <td class={"border-l-4 p-0 #{Utils.get_fixture_border_color(fixture.id, @selected_fixture_ids, @primary_selected_fixture_id)}"}>
                </td>
                <td class="border border-neutral-600 px-4 py-2">{fixture.label}</td>

                <td class="border border-neutral-600 px-4 py-2 font-monospace">{fixture.id}</td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
