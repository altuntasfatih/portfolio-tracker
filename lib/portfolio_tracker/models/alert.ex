defmodule Alert do
  defstruct type: nil,
            price: 0.0,
            function: nil

  def new(price, :lower_limit) do
    %Alert{
      type: :lower_limit,
      price: price,
      function: fn current_price, alert_price ->
        current_price <= alert_price
      end
    }
  end

  def new(price, :upper_limit) do
    %Alert{
      type: :upper_limit,
      price: price,
      function: fn current_price, alert_price ->
        current_price >= alert_price
      end
    }
  end

  def is_hit(%Alert{} = alert, current_price) do
    alert.function.(current_price, alert.price)
  end
end
