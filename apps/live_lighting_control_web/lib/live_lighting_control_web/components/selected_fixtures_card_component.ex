defmodule LiveLightingControlWeb.SelectedFixturesCardComponent do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS
  alias LiveLightingControl.Utils

  def render(assigns) do
    ~H"""
    <div class="w-full h-full flex flex-col">
      <% show_all = Map.get(@configuration, :show, false) == "all" %>
      <% attributes =
        @calculated_fixture_values |> Map.values() |> Enum.flat_map(&Map.keys/1) |> Enum.uniq() %>

      <div class="bg-neutral-700 p-2 rounded-t-lg" phx-click={JS.toggle(to: "#hidden-content-#{@id}")}>
        <h2 class="text-sm font-semibold">Fixtures</h2>
      </div>

      <div class="p-2 overflow-x-auto" id={"hidden-content-#{@id}"}>
        <div class="flex flex-row justify-end mb-2">
          <div
            class="bg-neutral-800 p-2 px-4 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer text-xs border-neutral-600 hover:border-neutral-400"
            phx-click="update_card_configuration"
            phx-value-value={
              if show_all do
                "selected"
              else
                "all"
              end
            }
            phx-value-key={:show}
            phx-value-card-id={@id}
          >
            <p class="text-sm">
              {if show_all do
                "Show only selected"
              else
                "Show all fixtures"
              end}
            </p>
          </div>
        </div>

        <table class="table-auto w-full border-collapse border border-neutral-600">
          <thead>
            <tr class="bg-neutral-800 text-gray-400">
              <th class="border-l-4 p-0 border-neutral-600 w-0"></th>
              <th class="border border-neutral-600 px-4 py-2 text-left w-36">Label</th>
              <th class="border border-neutral-600 px-4 py-2 text-left w-auto">Id</th>
              <%= for attribute <- attributes do %>
                <th class="border border-neutral-600 px-4 py-2 text-left w-auto">{attribute}</th>
              <% end %>
            </tr>
          </thead>

          <tbody>
            <% fixtures =
              if show_all do
                @fixtures
              else
                LiveLightingControl.Utils.get_selected_fixtures(@fixtures, @selected_fixture_ids)
              end %>
            <%= for fixture <- fixtures do %>
              <% attribute_map = Map.get(@calculated_fixture_values, fixture.id, %{}) %>
              <tr class="hover:bg-neutral-700 text-sm">
                <td class={"border-l-4 p-0 #{Utils.get_fixture_border_color(fixture.id, @selected_fixture_ids, @primary_selected_fixture_id)}"}>
                </td>
                <td class="border border-neutral-600 px-4 py-2">{fixture.label}</td>

                <td class="border border-neutral-600 px-4 py-2 font-monospace">{fixture.id}</td>
                <%= for attribute_key <- attributes do %>
                  <% attribute = Map.get(attribute_map, attribute_key, %{}) %>
                  <% attribute_value = Map.get(attribute, :value, nil) %>
                  <% attribute_source_type = Map.get(attribute, :type, nil) %>
                  <% attribute_source_type_color_class =
                    case attribute_source_type do
                      :highlight -> "text-white"
                      :programmer -> "text-blue-500"
                      :scene -> "text-orange-500"
                      _ -> ""
                    end %>
                  <td class={"border border-neutral-600 px-4 py-2 font-monospace #{attribute_source_type_color_class}"}>
                    {attribute_value}
                  </td>
                <% end %>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
