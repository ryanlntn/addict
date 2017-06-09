defmodule Addict.Interactors.GetUserByEmail do
  import Ecto.Query, only: [from: 2]

  @doc """
  Gets user by e-mail.
  Returns `{:ok, user}` or `{:error, [authentication: "Incorrect e-mail/password"]}`
  """
  def call(email, schema \\ Addict.Configs.user_schema, repo \\ Addict.Configs.repo) do
    alt_ids = Addict.Configs.alternate_unique_identifiers

    if alt_ids && !Enum.empty?(alt_ids) do
      query = Enum.reduce(alt_ids  ++ [:email], schema, fn key, user ->
        from u in user, or_where: field(u, ^key) == ^email
      end)

      query
      |> repo.one
      |> process_response
    else
      schema
      |> repo.get_by(email: email)
      |> process_response
    end
  end

  defp process_response(nil) do
    {:error, [authentication: "Incorrect e-mail/password"]}
  end

  defp process_response(user) do
    {:ok, user}
  end

end
