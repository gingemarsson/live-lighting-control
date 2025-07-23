defmodule LiveLightingControlWeb.ExecutorComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div class="w-24 bg-neutral-800 p-2 rounded-lg flex flex-col items-center justify-center border transition-colors border-neutral-600">
      <p class={"text-sm #{ if @value == 0, do: "text-gray-500", else: "" }"}>
        {@label}
      </p>

      <button
        phx-hook="ExecutorButtonHook"
        id={"executor-slider-button-#{@id}"}
        data-executor-id={@executor_id}
        class={"bg-neutral-800 py-1 w-16 my-2 rounded-lg flex flex-col items-center justify-center border transition-colors cursor-pointer disabled:cursor-default disabled:border-neutral-700 #{if @executor_active do "border-orange-600" else "border-neutral-600 hover:border-neutral-400" end}"}
        disabled={@executor_id == nil}
      >
        <p class="text-sm">{@button_label}</p>
      </button>

      <div class="text-sm text-gray-700 font-medium">
        {@value}
      </div>

      <form class="w-12 h-56 h-full">
        <.live_component
          module={LiveLightingControlWeb.VerticalSliderComponent}
          id={@id}
          value={@value}
          slider_id={@executor_id}
          slider_type={:executor}
        />
      </form>
    </div>
    """
  end
end
