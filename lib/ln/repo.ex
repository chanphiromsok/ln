defmodule Ln.Repo do
  use Ecto.Repo,
    otp_app: :ln,
    adapter: Ecto.Adapters.Postgres
end
