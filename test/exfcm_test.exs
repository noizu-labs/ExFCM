defmodule ExFCMTest do
  use ExUnit.Case
  doctest ExFCM

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "Sends message" do
    alias ExFCM.Message

    Process.sleep(1000)
    {:ok , result } = Message.put_data(%{"sample" => "true"})
    |> Message.put_notification("Tomasz","Cichocinski")
    |> Message.target_device("APA91bHCrEujT7EZPTiwU-ZAbHhyGVE0TLaYluE5jBk0hHqWFCbeXPQroGESsc408emLllTqzWysJ3WraS1BZakBZOBUy_vXfbU9oV4FW__GbEj6mnxsspPlS1Xq8pfGzq2gBPHcGyxrfXOb7f6vGtw6QCj8md9AUA")
    |> Message.send

    IO.inspect result.body
  end
end
