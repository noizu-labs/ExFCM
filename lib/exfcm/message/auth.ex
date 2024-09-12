
defmodule ExFCM.Message.Auth do
  defstruct [
    project: :default,
    service_account: :default,
    token: :default,
  ]

  @message_scope "https://www.googleapis.com/auth/firebase.messaging"

  def default_project(options \\ nil)
  def default_project(options) do
    cond do
      project = options[:project] -> {:ok, project}
      project = Application.get_env(:exfcm, :project, nil) -> {:ok, project}
      :else -> Goth.Config.get(:project_id)
    end
  end

  def default_service_account(options \\ nil)
  def default_service_account(options) do
    cond do
      service_account = options[:service_account] -> {:ok, service_account}
      service_account = Application.get_env(:exfcm, :service_account, nil) -> {:ok, service_account}
      :else -> {:ok, :default}
    end
  end

  def with_token(service_account, project, token, options \\ nil)
  def with_token(service_account, project, token, options) when token == nil or token == :default do
    cond do
      token = options[:token] -> {:ok, token}
      :else ->
        # Note this will throw if service account invalid
        Goth.Token.for_scope({service_account, @message_scope})
    end
  end
  def with_token(service_account, project, token = %Goth.Token{}, options) do
    cond do
      token = options[:token] -> {:ok, token}
      token.expires < :os.system_time(:seconds) ->
        # Note this will throw is service account invalid
        Goth.Token.for_scope({token.account, token.scope})
      :else -> {:ok, token}
    end
  end

  def effective(auth, options \\ nil)
  def effective(:default, options) do
    with {:ok, project} <- default_project(options),
         {:ok, service_account} <- default_service_account(options),
         {:ok, token} <- with_token(service_account, project, :default, options) do
      {:ok, %__MODULE__{project: project, service_account: service_account, token: token}}
    end
  end
  def effective(auth = %__MODULE__{}, options) do
    project = case auth.project do
      none when none == nil or none == :default -> default_project(options)
      project -> {:ok, project}
    end
    service_account = case auth.service_account do
      none when none == nil or none == :default -> default_service_account(options)
      service_account -> {:ok, service_account}
    end
    with {:ok, project} <- project,
         {:ok, service_account} <- service_account,
         {:ok, token} <- with_token(service_account, project, auth.token, options) do
      {:ok, %__MODULE__{project: project, service_account: service_account, token: token}}
    end
  end

end
