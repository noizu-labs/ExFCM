defmodule ExFCM.Message do

  @moduledoc """
  This module is used to manage and send Messages.

  To send a notification you have to provide a target using `target_device` (for a single device or group of devices) or using a `target_topic`.

  ## Examples

  ```

  {:ok , result } = Message.put_data(%{"sample" => "true"})
  |> Message.put_notification("Title","Description")
  |> Message.target_topic("sample_giveaways")
  |> Message.send

  ```

  """

  require Logger

  defstruct to: "", notification: nil, data: nil

  @url Application.get_env(:exfcm, :fcm_url, "")

  @fcm_endpoint "https://fcm.googleapis.com/v1"
  @messaging_scope "https://www.googleapis.com/auth/firebase.messaging"
  @server_key Application.get_env(:exfcm, :server_key, "")

  defmodule Notification do
    defstruct title: nil, body: nil, sound: nil
  end

  @doc """
  Puts a Notification inside message. It will be displayed in tray when app is in background.
  """

  def put_notification(message \\ %__MODULE__{}, title, data) do
    notification = %Notification{ title: title, body: data}
    %__MODULE__{message | notification: notification}
  end

  @doc """
  Puts a Audible Notification inside message. It will be displayed in tray when app is in background.
  """

  def put_audible_notification(message \\ %__MODULE__{}, title, data, sound) do
    notification = %Notification{ title: title, body: data, sound: sound}
    %__MODULE__{message | notification: notification}
  end

  @doc """
  Puts a data fieldd into sending json, if it's present the `onMessageReceived` callback will be called on client.
  """

  def put_data(message \\ %__MODULE__{}, data) do
    %__MODULE__{message | data: data}
  end


  @doc """
  Sets target of notification. It should be either legal DeviceID obtained through a proper callback on client side and sent or a registered device group id.
  """
  def target_device(message \\ %__MODULE__{}, device) do
    %{ message | to: device }
  end

  @doc """
  Sets target of notification. It should be only the name of the topic without "/topics/name".

  Topic has to match ``` [a-zA-Z0-9-_.~%]+  ``` regex.
  """

  def target_topic(message \\ %__MODULE__{}, topic) do
    %{message | to: "/topics/#{topic}"}
  end

  @doc """
  Sends synchronous message.
  """
  def send(message) do
    case :persistent_term.get(:exfcm_send_mode, :pending) do
      :pending ->
        case Application.get_env(:exfcm, :send_mode, :new) do
          :new ->
            :persistent_term.put(:exfcm_send_mode, :new)
            send_new(message)
          _ ->
            :persistent_term.put(:exfcm_send_mode, :old)
            send_old(message)
        end
      :new ->
        send_new(message)
        |> case do
             x = {:ok, %{status_code: 200}} -> x
             {:ok, x} ->
               Logger.warning("FCM Error: #{inspect x, pretty: true}")
               {:ok, x}
             x -> x
           end
      _ ->
        send_old(message)
    end
  end

  def send_old(message) do
    as_json = Poison.encode!(message)
    Logger.debug as_json
    HTTPoison.post(@url,
      as_json,
      [{ "Authorization", "key=" <> @server_key},
       {"Content-Type", "application/json"}])
  end


  def send_new(message) do
    with {:ok, project} <- Goth.Config.get(:project_id),
         {:ok, goth_token} <- Goth.Token.for_scope({:default, @messaging_scope}) do

        body = %{
          message: %{
            notification: %{
              title: message.notification.title,
              body: message.notification.body,
            },
          }
        }
        body = if String.starts_with?(message.to, "/topics/") do
          body
          |> put_in([:message, :topic], String.slice(message.to, 8..-1))
        else
          body
          |> put_in([:message, :token], message.to)
        end
        body = if (message.data) do
          data = Enum.map(message.data,
            fn
              {k,v} when is_map(v)  or is_list(v) or is_atom(v) or is_boolean(v) -> {k, Poison.encode!(v)}
              {k,v} -> {k,v}
            end
          ) |> Map.new()
          put_in(body, [:message, :data], data)
        else
          body
        end
        body = if (message.notification.sound) do
          body
          |> put_in([:message, :android], %{notification: %{sound: message.notification.sound}})
          |> put_in([:message, :apns],  %{payload: %{aps: %{sound: message.notification.sound}}})
        else
          body
        end # end if
        as_json = Poison.encode!(body)
        #Logger.warning as_json
        HTTPoison.post("#{@fcm_endpoint}/projects/#{project}/messages:send",
          as_json,
          [{ "Authorization", "Bearer " <> goth_token.token},
            {"Content-Type", "application/json"}])

    end # end with
  end # end def

end
