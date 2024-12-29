defmodule EcampusWeb.Dashboard.Index do
  @moduledoc """
  This module contains the dashboard
  """

  use EcampusWeb, :live_view
  use Gettext, backend: EcampusWeb.Gettext

  @impl true
  def mount(_params, %{"locale" => locale} = _session, socket) do
    Gettext.put_locale(EcampusWeb.Gettext, locale)
    {:ok, socket}
  end
end
