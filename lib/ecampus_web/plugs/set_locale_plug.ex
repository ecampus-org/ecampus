defmodule EcampusWeb.Plugs.SetLocale do
  @moduledoc """
  This module contains login to manage app locale in cookies.
  """

  import Plug.Conn

  @supported_locales Gettext.known_locales(EcampusWeb.Gettext)

  def init(_options), do: nil

  def call(%Plug.Conn{params: %{"locale" => locale}} = conn, _options)
      when locale in @supported_locales do
    case fetch_locale_from(conn) do
      nil ->
        conn

      locale ->
        EcampusWeb.Gettext |> Gettext.put_locale(locale)

        conn
        |> put_resp_cookie("locale", locale, max_age: 365 * 24 * 60 * 60)
        |> put_session(:locale, locale)
    end
  end

  def call(conn, _options), do: conn

  defp fetch_locale_from(conn) do
    (conn.params["locale"] || conn.cookies["locale"])
    |> check_locale
  end

  defp check_locale(locale) when locale in @supported_locales, do: locale
  defp check_locale(_), do: nil
end
