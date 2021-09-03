defmodule Alert do
  defstruct type: nil,
            stock_name: "",
            price: 0.0,
            function: nil

  @type t :: %Alert{
          type: atom(),
          stock_name: String.t(),
          price: float(),
          function: function()
        }

  @spec new(:lower_limit | :upper_limit, String.t(), float()) :: Alert.t()
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

  @spec is_hit(Alert.t(), float()) :: boolean()
  def is_hit(%Alert{} = alert, current_price) do
    alert.function.(current_price, alert.price)
  end
end
