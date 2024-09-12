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
  alias ExFCM.Message.{Auth, Notification}
  require Logger

  defstruct [
    auth: :default,

    topic: nil,
    token: nil,

    notification: nil,
    data: nil,
    webpush: nil,
    android: nil,
    apns: nil,
  ]


  @doc """
  Specify firebase project to use for sending message.
  """
  def with_project(message \\ %__MODULE__{}, project)
  def with_project(message = %__MODULE__{auth: auth}, project) when is_nil(auth) or auth == :default do
    auth = %Auth{project: project}
    %{message | auth: auth}
  end
  def with_project(message = %__MODULE__{auth: auth = %Auth{}}, project) do
    auth = %Auth{auth| project: project}
    %{message | auth: auth}
  end


  @doc """
  Specify firebase service account to use for sending message.
  """
  def with_service_account(message \\ %__MODULE__{}, account)
  def with_service_account(message = %__MODULE__{auth: auth}, service_account) when is_nil(auth) or auth == :default do
    auth = %Auth{service_account: service_account}
    %{message | auth: auth}
  end
  def with_service_account(message = %__MODULE__{auth: auth = %Auth{}}, service_account) do
    auth = %Auth{auth| service_account: service_account}
    %{message | auth: auth}
  end


  @doc """
  Specify firebase bearer token to use when sending message.
  """
  def with_token(message \\ %__MODULE__{}, token)
  def with_token(message = %__MODULE__{auth: auth}, token) when is_nil(auth) or auth == :default do
    auth = %Auth{token: token}
    %{message | auth: auth}
  end
  def with_token(message = %__MODULE__{auth: auth = %Auth{}}, token) do
    auth = %Auth{auth| token: token}
    %{message | auth: auth}
  end

  @doc """
  Puts a Notification inside message. It will be displayed in tray when app is in background.
  """
  def put_notification(message \\ %__MODULE__{}, title, data)
  def put_notification(message = %__MODULE__{}, title, data) do
    notification = %Notification{title: title, body: data}
    %__MODULE__{message | notification: notification}
  end

  @doc """
  Puts an Audible Notification inside message. It will be displayed in tray when app is in background.
  """
  def put_audible_notification(message \\ %__MODULE__{}, title, data, sound) do
    notification = %Notification{title: title, body: data, sound: sound}
    %__MODULE__{message | notification: notification}
  end

  @doc """
  Set notification title.
  """
  def put_notification_title(message \\ %__MODULE__{}, title)
  def put_notification_title(message = %__MODULE__{notification: nil}, title) do
    notification = %Notification{title: title}
    %__MODULE__{message | notification: notification}
  end
  def put_notification_title(message = %__MODULE__{notification: %Notification{} = notification}, title) do
    notification = %Notification{notification| title: title}
    %__MODULE__{message | notification: notification}
  end

  @doc """
  Set notification body.
  """
  def put_notification_body(message \\ %__MODULE__{}, body)
  def put_notification_body(message = %__MODULE__{notification: nil}, body) do
    notification = %Notification{body: body}
    %__MODULE__{message | notification: notification}
  end
  def put_notification_body(message = %__MODULE__{notification: %Notification{} = notification}, body) do
    notification = %Notification{notification| body: body}
    %__MODULE__{message | notification: notification}
  end


  @doc """
  Set notification sound.
  """
  def put_notification_sound(message \\ %__MODULE__{}, sound)
  def put_notification_sound(message = %__MODULE__{notification: nil}, sound) do
    notification = %Notification{sound: sound}
    %__MODULE__{message | notification: notification}
  end
  def put_notification_sound(message = %__MODULE__{notification: %Notification{} = notification}, sound) do
    notification = %Notification{notification| sound: sound}
    %__MODULE__{message | notification: notification}
  end





  @doc """
  Puts a data field into sending json, if it's present the `onMessageReceived` callback will be called on client.
  """
  def put_data(message \\ %__MODULE__{}, data) do
    %__MODULE__{message | data: data}
  end


  @doc """
  Sets target of notification. It should be either legal DeviceID obtained through a proper callback on client side and sent or a registered device group id.
  """
  def target_device(message \\ %__MODULE__{}, device_token) do
    %{ message | token: device_token }
  end

  @doc """
  Sets target of notification. It should be only the name of the topic without "/topics/name".

  Topic has to match ``` [a-zA-Z0-9-_.~%]+  ``` regex.
  """
  def target_topic(message \\ %__MODULE__{}, topic_name) do
    %{message | topic: "/topics/#{topic_name}"}
  end

  @doc """
  Sends synchronous message.
  """

  def send(message) do
    ExFCM.Firebase.send(message)
  end
  def send(message, options) do
    ExFCM.Firebase.send(message, options)
  end

  defimpl Jason.Encoder do
    def encode(subject, opts) do
      Jason.Encode.map(%{message: %{token: subject.token, data: subject.data, notification: %{title: "test", body: "body2"}}}, opts)
    end
  end
end
