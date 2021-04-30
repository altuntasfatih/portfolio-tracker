defmodule Alert do
  defstruct type: nil,
            stock_id: "",
            price: 0.0,
            function: nil

  def new(:lower_limit, stock_id, price) do
    %Alert{
      type: :lower_limit,
      stock_id: stock_id,
      price: price,
      function: fn current_price, alert_price ->
        current_price <= alert_price
      end
    }
  end

  def new(:upper_limit, stock_id, price) do
    %Alert{
      type: :upper_limit,
      stock_id: stock_id,
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
      "#{alert.id} -> #{Atom.to_string(alert.type)} on #{alert.price}"
    end
  end
end
