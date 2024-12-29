defmodule EcampusWeb.Dashboard.Program do
  @moduledoc """
  This module contains the program page in the dashboard
  """

  use EcampusWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
