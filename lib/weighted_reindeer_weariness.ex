defmodule WeightedReindeerWeariness do
  @north_pole %{lat: 90.0, lng: 0.0}
  @sleigh_weight 10.0

  def score(all_trips) do
    trip_numbers = Enum.map(all_trips, fn(x) -> x[:trip_id] end) |> Enum.uniq

    Enum.each(trip_numbers, fn(trip_number) ->
      IO.puts "Trip #: #{trip_number}"
      single_trip = Enum.filter(all_trips, fn(x) -> x[:trip_id] == trip_number end)

      trip_weight = Enum.map(single_trip, fn(x) -> x[:weight] end)
        |> Enum.sum
        |> + @sleigh_weight
      weighted_dist = sum_weighted_dist(single_trip, trip_weight)
      IO.puts "Trip Total: #{weighted_dist}"
      weighted_dist
    end)
  end

  def sum_weighted_dist(gifts, remaining_weight), do: sum_weighted_dist(gifts, remaining_weight, @north_pole, 0)

  def sum_weighted_dist([], remaining_weight, prev, acc) do
    acc + Haversine.distance({prev[:lat], prev[:lng]},
      {@north_pole[:lat], @north_pole[:lng]}) * remaining_weight
  end

  def sum_weighted_dist([head | tail], remaining_weight, prev, acc) do
    sum_weighted_dist(tail, remaining_weight - head[:weight], head,
      acc + Haversine.distance(
        {prev[:lat], prev[:lng]}, {head[:lat], head[:lng]}) * remaining_weight )
  end


  # def sum_weights(gifts), do: sum_weights(gifts, 0)
  #
  # def sum_weights([], acc) do
  #   acc
  # end
  #
  # def sum_weights([head | tail], acc) do
  #   sum_weights(tail, acc + head)
  # end


end
