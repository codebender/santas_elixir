defmodule SantasElixir do
  @gifts_csv "input/gifts.csv"
  @clusters_csv "input/clusters.csv"

  def do_magic do
    gifts = load_gifts
    trips = load_trips
    #trips = Enum.filter(trips, fn(x) -> x[:trip_id] == 1 end)

    Benchmark.measure(fn -> merge_trips_gifts(trips, gifts) end)
      |> IO.puts

    Benchmark.measure(fn -> quick_merge_trips_gifts(trips, gifts) end)
      |> IO.puts

    merged = quick_merge_trips_gifts(trips, gifts)

    Benchmark.measure(fn -> WeightedReindeerWeariness.score(merged) end)
      |> IO.puts


  end

  def load_gifts do
    load_csv(@gifts_csv)
      |> Enum.map( fn(x) ->
           %{gift_id: String.to_integer(x["GiftId"]),
             lat: String.to_float(x["Latitude"]),
             lng: String.to_float(x["Longitude"]),
             weight: String.to_float(x["Weight"])}
         end)
  end

  def load_trips do
    load_csv(@clusters_csv)
      |> Enum.map( fn(x) ->
           %{gift_id: String.to_integer(x["GiftId"]),
             trip_id: String.to_integer(x["TripId"])}
         end)
  end

  def load_csv(csv_path) do
    File.stream!(csv_path)
      |> CSV.decode(headers: true)
      |> Enum.into([])
  end

  def merge_trips_gifts(trips, gifts) do
    Enum.map(trips, fn(trip) ->
      Map.merge(trip, Enum.find(gifts, fn(y) -> y[:gift_id] == trip[:gift_id] end))
    end)
  end

  def quick_merge_trips_gifts(trips, gifts) do
    sorted_trips = Enum.with_index(trips) |> Enum.sort_by(fn(trip) -> elem(trip, 0)[:gift_id] end)

    Enum.map(0..length(sorted_trips)-1, fn(x) ->
      { Map.merge(elem(Enum.at(sorted_trips,x),0), Enum.at(gifts,x)),
        elem(Enum.at(sorted_trips,x),1) }
    end)
      |> Enum.sort_by(fn(trip) ->
        elem(trip, 1)
      end)
      |> Enum.map(fn(x) ->
        elem(x, 0)
      end)
  end
end
