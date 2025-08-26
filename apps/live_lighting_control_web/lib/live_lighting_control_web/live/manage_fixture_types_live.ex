defmodule LiveLightingControlWeb.ManageFixtureTypesLive do
  use LiveLightingControlWeb, :live_view
  require UUID


  # Mount and state
  #

  def mount(_params, _session, socket) do
    state = LiveLightingControl.StateManager.get_state()
    Phoenix.PubSub.subscribe(LiveLightingControl.PubSub, "state")
    {:ok, assign(socket, state: state)}
  end

  def handle_info({:state_update, updated_state}, socket) do
    {:noreply, assign(socket, :state, updated_state)}
  end

  # Handle params
  #

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:fixture_type, nil)
  end

  defp apply_action(socket, :new, _params) do
    fixture_type = %LiveLightingControlWeb.Changeset.FixtureType{
      id: UUID.uuid4(),
      label: "",
      channels: []
    }

    changeset = LiveLightingControlWeb.Changeset.FixtureType.changeset(fixture_type, %{})
    assign(socket, fixture_type: changeset, live_action: :new)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    fixture_types = socket.assigns.state.fixture_types
    fixture_type_model = Enum.find(fixture_types, fn fixture_type -> fixture_type.id == id end)

    changeset =
      LiveLightingControlWeb.Changeset.Converter.fixture_type_to_changeset(fixture_type_model)

    assign(socket, :fixture_type, changeset)
  end


  # Buttons
  #

  def handle_event("save", %{"fixture_type" => params}, socket) do
    changeset =
      LiveLightingControlWeb.Changeset.FixtureType.changeset(
        %LiveLightingControlWeb.Changeset.FixtureType{},
        params
      )

    if changeset.valid? do
      model = LiveLightingControlWeb.Changeset.Converter.changeset_to_model(changeset)
      LiveLightingControl.StateManager.update_fixture_type(model)
      {:noreply, assign(socket, fixture_type: changeset)}
    else
      {:noreply, assign(socket, fixture_type: changeset)}
    end
  end

  def handle_event("add_channel", _params, socket) do
    changeset = socket.assigns.fixture_type

    # Add a new empty channel
    channels =
      changeset.changes[:channels] || Ecto.Changeset.get_field(changeset, :channels)

    channels =
      channels ++ [%LiveLightingControlWeb.Changeset.FixtureTypeChannel{id: UUID.uuid4()}]

    changeset =
      Ecto.Changeset.put_embed(changeset, :channels, channels)

    {:noreply, assign(socket, fixture_type: changeset)}
  end

  def handle_event("remove_channel", %{"id" => channel_id}, socket) do
    changeset = socket.assigns.fixture_type

    # Get current channels
    channels =
      Ecto.Changeset.get_field(changeset, :channels)
      |> Enum.reject(&(&1.id == channel_id))

    # Update the changeset with remaining channels
    changeset = Ecto.Changeset.put_embed(changeset, :channels, channels)

    {:noreply, assign(socket, fixture_type: changeset)}
  end

  def render(assigns) do
    ~H"""
    <%= if @live_action in [:new, :edit] do %>
      <.modal id="fixture-type-modal" show on_cancel={JS.patch(~p"/manage-fixture-types")}>
        <.simple_form :let={f} for={@fixture_type} id="fixture-type-form" phx-submit="save">
          <.input field={f[:id]} label="ID" readonly class="bg-gray-100 cursor-not-allowed" />
          <.input field={f[:label]} label="Label" />

          <h3 class="mt-4 font-semibold">Channels</h3>
          <.inputs_for :let={cf} field={f[:channels]}>
            <div class="flex gap-4 items-end">
              <.input field={cf[:attribute]} label="Attribute" />
              <.input field={cf[:dmx_address]} type="number" label="DMX Address" />
              <.input field={cf[:type]} label="Type" />
              <.input field={cf[:default_value]} type="number" label="Default Value" />
              <.button
                type="button"
                phx-click="remove_channel"
                phx-value-id={cf[:id].value}
                class="bg-red-500 text-white px-2 py-1 rounded"
              >
                Remove
              </.button>
            </div>
          </.inputs_for>

          <.button type="button" phx-click="add_channel" class="mt-2 w-32">
            Add Channel
          </.button>

          <:actions>
            <.button>Save</.button>
            <.button type="button" phx-click={JS.patch(~p"/manage-fixture-types")}>
              Cancel
            </.button>
          </:actions>
        </.simple_form>
      </.modal>
    <% end %>

    <div class="flex-grow w-full max-w-[1920px] mx-auto flex flex-col gap-4 p-4 pb-96">
      <div class="bg-neutral-800 rounded-lg shadow-md">
        <div class="w-full h-fullflex flex-col">
          <div class="bg-neutral-700 p-2 rounded-t-lg">
            <h2 class="text-sm font-semibold">Fixture Types</h2>
          </div>
          <div class="flex flex-col p-2">
            <div class="grid grid-cols-8 gap-2">
              <%= for fixture_type <- Enum.sort_by(@state.fixture_types, fn fixture_type -> fixture_type.label end, :desc) do %>
                <div class="bg-neutral-800 p-2 rounded-lg flex flex-col items-center justify-center border transition-colors border-neutral-500">
                  <p class="">{fixture_type.label}</p>
                  <p class="text-sm text-neutral-400">
                    {length(fixture_type.channels)} channels
                  </p>
                  <div class="flex flex-row gap-2">
                    <.link
                      patch={~p"/manage-fixture-types/#{fixture_type.id}/edit"}
                      class="bg-neutral-800 py-1 w-16 my-2 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer disabled:cursor-default disabled:border-neutral-700 border-neutral-600 hover:border-neutral-400 active:border-orange-600"
                    >
                      <p class="text-xs">Edit</p>
                    </.link>
                    <button
                      type="button"
                      phx-click="delete-fixture-type"
                      phx-value-fixture-type-id={fixture_type.id}
                      class="bg-neutral-800 py-1 w-16 my-2 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer disabled:cursor-default disabled:border-neutral-700 border-neutral-600 hover:border-neutral-400 active:border-orange-600"
                    >
                      <p class="text-xs">Delete</p>
                    </button>
                  </div>
                </div>
              <% end %>

              <button
                phx-click={JS.patch(~p"/manage-fixture-types/new")}
                class="bg-neutral-800 p-2 rounded-lg flex flex-col items-center justify-center border transition-colors border-neutral-500"
              >
                Add new fixture type
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
