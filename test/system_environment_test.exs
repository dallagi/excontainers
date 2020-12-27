defmodule SystemEnvironmentTest do
  use ExUnit.Case, async: true

  test "returns environment variable value when it exists" do
    assert SystemEnvironment.get("PWD") =~ "/"
  end

  test "returns default when environment variable does not exist" do
    unexisting_env_var = "UNEXISTING_VARIABLE_#{UUID.uuid4()}"

    assert SystemEnvironment.get(unexisting_env_var, "default_value") == "default_value"
  end
end
