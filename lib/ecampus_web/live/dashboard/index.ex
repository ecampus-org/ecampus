defmodule EcampusWeb.Dashboard.Index do
  use EcampusWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
