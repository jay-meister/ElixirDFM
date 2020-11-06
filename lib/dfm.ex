defmodule DFM do
  @moduledoc """
  A Lana Labs test task - Direct Followers matrix.
  """

  alias NimbleCSV.RFC4180, as: CSV

  @type matrix() :: map()
  @type filters() :: [] | [from: DateTime.t(), to: DateTime.t()]

  @example_path Path.join(:code.priv_dir(:dfm), "IncidentExample.csv")

  @doc """
  Public function:

    run()
    run(from: DateTime{}, to: DateTime{})
  """
  def run(filters \\ []) do
    parse(@example_path)
    |> Enum.filter(&allow_trace?(&1, filters))
    |> build_matrix()
    |> output_matrix()
  end

  @spec parse(String.t()) :: list(DFM.Trace.t())
  def parse(path) do
    path
    |> File.stream!()
    |> CSV.parse_stream()
    |> Stream.map(fn [case_id, activity, start, _complete, _classification] ->
      %{case_id: case_id, event: %DFM.Event{activity: activity, start: parse_timestamp!(start)}}
    end)
    |> Enum.group_by(& &1.case_id, & &1.event)
    |> Enum.map(fn {case_id, events} ->
      %DFM.Trace{id: case_id, events: Enum.sort_by(events, & &1.start)}
    end)
  end

  @spec build_matrix(list(DFM.Trace.t())) :: matrix()
  def build_matrix(traces) do
    Enum.reduce(traces, %{}, fn trace, acc ->
      traverse_trace(trace.events, acc)
    end)
  end

  @spec traverse_trace(list(DFM.Event.t()), matrix()) :: matrix()
  defp traverse_trace([_ev1], acc),
    do: acc

  defp traverse_trace([ev1, ev2 | tail], acc),
    do: traverse_trace([ev2 | tail], add_follower(acc, ev1, ev2))

  @doc """
  add_follower(acc, event1, event2)
  adds a direct follower relationship to the matrix, from event1 to event2
  """
  @spec add_follower(matrix(), DFM.Event.t(), DFM.Event.t()) :: matrix()
  def add_follower(acc, %DFM.Event{} = ev1, %DFM.Event{} = ev2) do
    add_follower(acc, ev1.activity, ev2.activity)
  end

  def add_follower(acc, activity_1, activity_2) when is_map_key(acc, activity_1) do
    Kernel.update_in(acc[activity_1][activity_2], &((&1 || 0) + 1))
  end

  def add_follower(acc, activity_1, activity_2) do
    Map.put(acc, activity_1, Map.put(%{}, activity_2, 1))
  end

  @spec parse_timestamp!(String.t()) :: DateTime.t()
  defp parse_timestamp!(datetime) do
    [date, time] = String.split(datetime, " ")

    date = String.replace(date, "/", "-") |> Date.from_iso8601!()
    time = Time.from_iso8601!(time)

    {:ok, dt} = DateTime.new(date, time, "Etc/UTC")
    dt
  end

  @spec output_matrix(matrix()) :: matrix()
  defp output_matrix(acc) do
    acc
    |> Enum.map(fn {activity_1, followers} ->
      followers =
        Enum.map(followers, fn {activity_2, count} ->
          "\t#{activity_2}: #{count}"
        end)
        |> Enum.join("\n")

      "#{activity_1} => \n#{followers}"
    end)
    |> Enum.join("\n\n")
    |> IO.puts()

    acc
  end

  @spec allow_trace?(DFM.Trace.t(), filters()) :: boolean()
  def allow_trace?(_trace, []), do: true

  def allow_trace?(trace, from: from, to: to) do
    trace.events
    |> Enum.all?(fn event ->
      DateTime.compare(from, event.start) in [:lt, :eq] and
        DateTime.compare(event.start, to) in [:lt, :eq]
    end)
  end
end
