defmodule LiveLightingControlUtils do
  def update_item_by_id(list, id, updates) do
    Enum.map(list, fn
      %{id: ^id} = item -> Map.merge(item, updates)
      other -> other
    end)
  end
end
