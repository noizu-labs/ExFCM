
defmodule ExFCM.Message.Notification do
  @derive Jason.Encoder
  defstruct [
    title: nil,
    body: nil,
    sound: nil
  ]
end
