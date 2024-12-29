defmodule EcampusWeb.Dashboard.Files do
  @moduledoc """
  This module contains the files page in the dashboard
  """

  use EcampusWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
