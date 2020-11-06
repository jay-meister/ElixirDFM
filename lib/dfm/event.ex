defmodule DFM.Event do
  @moduledoc """
  An atomic data point in process mining domain.

  It represents the digital footprint of one unit of work, also called *activity*
  (e.g. "receive user application", "send invoice", "process order", "ship parcel" etc.),
  that was done and logged in a given process.

  It contains at least one timestamp, and the name of the *activity* which produced the *event*.

  Eventus usually also contain relevant *attributes* which can be either numeric or nominal,
  and contain any additional information needed.
  """

  defstruct [:activity, :start]

  @type t :: %__MODULE__{
          activity: String.t(),
          start: DateTime.t()
        }
end
