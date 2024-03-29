defmodule Util do
  def round_ceil(number) when is_integer(number) do
    (number / 1) |> round_ceil()
  end

  def round_ceil(number) when is_float(number) do
    Float.ceil(number, 2)
  end

  def round_(number) when is_integer(number) do
    (number / 1) |> Float.round(2)
  end

  def round_(number) when is_float(number) do
    Float.round(number, 2)
  end

  def rate(r) when r < 0, do: "-% #{r} 🔴"
  def rate(r) when r >= 0, do: "+% #{r} 🟢"
end
