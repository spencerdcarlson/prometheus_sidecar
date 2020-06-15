defmodule PrometheusSidecarTest do
  use ExUnit.Case
  doctest PrometheusSidecar

  test "greets the world" do
    assert PrometheusSidecar.hello() == :world
  end
end
