defmodule ExFCM.Firebase do
  # @TODO allow library callers to specify adapter
  use Tesla
  plug Tesla.Middleware.BaseUrl, "https://fcm.googleapis.com/v1"
  plug Tesla.Middleware.JSON
  adapter Tesla.Adapter.Finch, name: ExFCM.Finch




  @doc """
  Send a message
  """
  def send(message, options \\ nil)
  def send(message, options) do
    with {:ok, auth} <- ExFCM.Message.Auth.effective(message.auth, options),
            {:ok, url} <- send_message_url(auth),
        {:ok, headers} <- auth_header(auth) do
      __MODULE__.post(url, message, headers: headers)
      #{:ok, {:wip, auth, body}}
    end
    #,
    #         {:ok, body} <- Jason.encode(message)
    #as_json = Poison.encode!(message)
    #    Logger.debug as_json
    #    HTTPoison.post(@url,
    #      as_json,
    #      [{ "Authorization", "key=" <> @server_key},
    #       {"Content-Type", "application/json"}])
  end


  defp send_message_url(auth, options \\ nil)
  defp send_message_url(%ExFCM.Message.Auth{project: project}, _) do
    {:ok, "/projects/#{project}/messages:send"}
  end

  defp auth_header(auth, options \\ nil)
  defp auth_header(%ExFCM.Message.Auth{token: %Goth.Token{token: bearer_token}}, _) do
    {:ok, [{"Authorization","Bearer #{bearer_token}"}]}
  end
end
