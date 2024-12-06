defmodule Ecampus.Repo do
  use Ecto.Repo,
    otp_app: :ecampus,
    adapter: Ecto.Adapters.Postgres
end
