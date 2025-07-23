defmodule LiveLightingControlWeb.VerticalSliderComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="VerticalSlider"
      data-value={@value}
      data-slider-id={@slider_id}
      data-slider-type={@slider_type}
      class="relative w-full h-full bg-neutral-700 rounded cursor-pointer"
    >
      <!-- Filled portion -->
      <div
        class="absolute bottom-0 left-0 w-full bg-neutral-500 rounded"
        style={"height: #{@value/2.55}%"}
      >
      </div>
    </div>
    """
  end
end
