defmodule AlertTest do
  use ExUnit.Case

  test "it_should_hit_lower_limit" do
    alert = Alert.new(:lower_limit, "btc", 12.25)
    assert Alert.is_hit(alert, 12.00) == true
  end

  test "it_should_hit_upper_limit" do
    alert = Alert.new(:upper_limit, "avax", 13.25)
    assert Alert.is_hit(alert, 14.00) == true
  end
end
