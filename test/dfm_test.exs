defmodule DfmTest do
  use ExUnit.Case
  doctest DFM

  @sample_csv File.cwd!() |> Path.join("test/fixtures/sample.csv")

  describe "DFM.parse" do
    test "returns list of traces" do
      assert [%DFM.Trace{events: [_, _, _]}] = DFM.parse(@sample_csv)
    end
  end

  describe "DFM.build_matrix" do
    test "discards trace with single event" do
      trace = %DFM.Trace{id: "trace 1", events: [%DFM.Event{activity: :ev1}]}

      assert DFM.build_matrix([trace]) == %{}
    end

    test "traverses a single trace" do
      trace = %DFM.Trace{
        id: "trace 1",
        events: [
          %DFM.Event{activity: :ev1},
          %DFM.Event{activity: :ev2},
          %DFM.Event{activity: :ev3}
        ]
      }

      assert DFM.build_matrix([trace]) == %{ev1: %{ev2: 1}, ev2: %{ev3: 1}}
    end

    test "traverses 2 traces" do
      traces = [
        %DFM.Trace{
          id: "trace 1",
          events: [
            %DFM.Event{activity: :ev1},
            %DFM.Event{activity: :ev2},
            %DFM.Event{activity: :ev3}
          ]
        },
        %DFM.Trace{
          id: "trace 2",
          events: [
            %DFM.Event{activity: :ev1},
            %DFM.Event{activity: :ev2},
            %DFM.Event{activity: :ev3}
          ]
        }
      ]

      assert DFM.build_matrix(traces) == %{ev1: %{ev2: 2}, ev2: %{ev3: 2}}
    end
  end

  describe "DFM.add_follower" do
    test "direct follower relationship exists" do
      acc = %{ev1: %{ev2: 1}}
      assert DFM.add_follower(acc, :ev1, :ev2) == %{ev1: %{ev2: 2}}
    end

    test "first event exists, but new direct follower" do
      acc = %{ev1: %{}}
      assert DFM.add_follower(acc, :ev1, :ev2) == %{ev1: %{ev2: 1}}
    end

    test "first event does not exist" do
      acc = %{}
      assert DFM.add_follower(acc, :ev1, :ev2) == %{ev1: %{ev2: 1}}
    end
  end

  describe "DFM.allow_trace?" do
    test "reject if not in range" do
      trace = %DFM.Trace{
        events: [
          %DFM.Event{start: ~U[2020-01-01 08:00:00Z]}
        ]
      }

      assert DFM.allow_trace?(trace, from: ~U[2020-01-01 08:01:00Z], to: ~U[2020-01-01 09:00:00Z]) ==
               false
    end

    test "allow in range" do
      trace = %DFM.Trace{
        events: [
          %DFM.Event{start: ~U[2020-01-01 08:00:00Z]}
        ]
      }

      assert DFM.allow_trace?(trace, from: ~U[2020-01-01 07:00:00Z], to: ~U[2020-01-01 09:00:00Z]) ==
               true
    end

    test "allow if timestamp is on border" do
      trace = %DFM.Trace{
        events: [
          %DFM.Event{start: ~U[2020-01-01 08:00:00Z]}
        ]
      }

      assert DFM.allow_trace?(trace,
               from: ~U[2020-01-01 08:00:00Z],
               to: ~U[2020-01-01 09:00:00Z]
             ) ==
               true

      assert DFM.allow_trace?(trace,
               from: ~U[2020-01-01 07:00:00Z],
               to: ~U[2020-01-01 08:00:00Z]
             ) ==
               true
    end
  end
end
