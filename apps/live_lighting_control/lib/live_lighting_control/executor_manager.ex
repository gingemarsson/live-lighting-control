defmodule LiveLightingControl.ExecutorManager do
  use GenServer

  alias LiveLightingControl.ExecutorPage
  alias LiveLightingControl.Executor
  alias LiveLightingControl.Utils

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @spec get_executor_pages() :: [ExecutorPage.t()]
  def get_executor_pages do
    GenServer.call(__MODULE__, :get_executor_pages)
  end

  def handle_executor_slider(executor_id, new_value) do
    GenServer.cast(
      __MODULE__,
      {:handle_executor_slider, %{executor_id: executor_id, new_value: new_value}}
    )
  end

  def handle_executor_action(executor_id, action) do
    GenServer.cast(
      __MODULE__,
      {:handle_executor_slider, %{executor_id: executor_id, action: action}}
    )
  end

  # Server Callbacks

  @impl true
  def init(_args) do
    executor_pages = [
      %ExecutorPage{
        id: "07c82518-62dc-4ddc-8db9-2c745f0a2f10",
        label: "Page 1",
        executors: [
          [
            %Executor{
              id: UUID.uuid4(),
              type: :scene,
              entity_id: "69ac89df-fdaf-481d-9788-d522a159a465",
              button_type: :flash
            },
            %Executor{
              id: UUID.uuid4(),
              type: :scene,
              entity_id: "4b17863d-99f3-4ce9-bacb-e9e3e67b9b31",
              button_type: :flash
            },
            %Executor{
              id: UUID.uuid4(),
              type: :scene,
              entity_id: "7b7f7fc7-69c0-4eb2-86a5-22fa8e2d1144",
              button_type: :flash
            },
            %Executor{
              id: UUID.uuid4(),
              type: :scene,
              entity_id: "00d0b87a-c9f7-4727-84a7-841f15c9fcae",
              button_type: :flash
            }
          ],
          [
            %Executor{
              id: UUID.uuid4(),
              type: :scene,
              entity_id: "69ac89df-fdaf-481d-9788-d522a159a465",
              button_type: :flash
            },
            %Executor{
              id: UUID.uuid4(),
              type: :scene,
              entity_id: "4b17863d-99f3-4ce9-bacb-e9e3e67b9b31",
              button_type: :flash
            },
            %Executor{
              id: UUID.uuid4(),
              type: :scene,
              entity_id: "7b7f7fc7-69c0-4eb2-86a5-22fa8e2d1144",
              button_type: :flash
            },
            %Executor{
              id: UUID.uuid4(),
              type: :scene,
              entity_id: "00d0b87a-c9f7-4727-84a7-841f15c9fcae",
              button_type: :flash
            }
          ],
          [],
          [],
          []
        ]
      }
    ]

    {:ok, executor_pages}
  end

  @impl true
  def handle_call(:get_executor_pages, _from, executor_pages) do
    {:reply, executor_pages, executor_pages}
  end

  @impl true
  def handle_cast(
        {:handle_executor_slider, %{executor_id: executor_id, new_value: new_value}},
        executor_pages
      ) do
    executors = Enum.flat_map(executor_pages, fn page -> List.flatten(page.executors) end)
    executor = Enum.find(executors, fn %Executor{id: id} -> id == executor_id end)

    case executor do
      nil ->
        nil

      %{type: :scene, entity_id: entity_id} ->
        LiveLightingControl.SceneManager.update_scene(%{
          id: entity_id,
          state: %{master: new_value}
        })
    end

    {:noreply, executor_pages}
  end

  @impl true
  def handle_cast(
        {:handle_executor_slider, %{executor_id: executor_id, action: action}},
        executor_pages
      ) do
    executors = Enum.flat_map(executor_pages, fn page -> List.flatten(page.executors) end)
    executor = Enum.find(executors, fn %Executor{id: id} -> id == executor_id end)

    case {executor, action} do
      {nil, _} ->
        nil

      {%{type: :scene, entity_id: entity_id, button_type: :flash}, :button_down} ->
        LiveLightingControl.SceneManager.update_scene(%{id: entity_id, state: %{flash: true}})

      {%{type: :scene, entity_id: entity_id, button_type: :flash}, :button_up} ->
        LiveLightingControl.SceneManager.update_scene(%{id: entity_id, state: %{flash: false}})

      {_, _} ->
        nil
    end

    updated_executor_pages =
      update_executor_by_id(executor_pages, executor_id, fn x ->
        Utils.deep_merge(x, %{state: %{active: action == :button_down}})
      end)

    notify_executor_updated(updated_executor_pages)

    {:noreply, updated_executor_pages}
  end

  defp notify_executor_updated(updated_executor_pages) do
    Phoenix.PubSub.broadcast(
      LiveLightingControl.PubSub,
      "executor",
      {:executor_updated, updated_executor_pages}
    )
  end

  defp update_executor_by_id(pages, target_id, update_fn) when is_list(pages) do
    Enum.map(pages, fn page ->
      %ExecutorPage{page | executors: update_executors_2d(page.executors, target_id, update_fn)}
    end)
  end

  defp update_executors_2d(executors_2d, target_id, update_fn) do
    Enum.map(executors_2d, fn row ->
      Enum.map(row, fn
        %Executor{id: ^target_id} = exec -> update_fn.(exec)
        exec -> exec
      end)
    end)
  end
end
