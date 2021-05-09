defmodule Alert do
  defstruct type: nil,
            stock_name: "",
            price: 0.0,
            function: nil

  def new(:lower_limit, stock_name, price) do
    %Alert{
      type: :lower_limit,
      stock_name: stock_name,
      price: price,
      function: fn current_price, alert_price ->
        current_price <= alert_price
      end
    }
  end

  def new(:upper_limit, stock_name, price) do
    %Alert{
      type: :upper_limit,
      stock_name: stock_name,
      price: price,
      function: fn current_price, alert_price ->
        current_price >= alert_price
      end
    }
  end

  def is_hit(%Alert{} = alert, current_price) do
    alert.function.(current_price, alert.price)
  end

  defimpl String.Chars, for: Alert do
    def to_string(alert) do
      "For #{alert.stock_name} #{Atom.to_string(alert.type)} on #{alert.price} "
    end
  end
end
