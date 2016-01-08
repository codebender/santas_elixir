defmodule SantasElixir do
  @gifts_csv "input/gifts.csv"
  @clusters_csv "input/clusters.csv"

  def do_magic do
    gifts = load_gifts
    trips = load_trips
    #trips = Enum.filter(trips, fn(x) -> x[:trip_id] == 1 end)

    merged = merge_trips_gifts(trips, gifts)

    WeightedReindeerWeariness.score(merged)
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
end
