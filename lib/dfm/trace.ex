defmodule DFM.Trace do
  @moduledoc """
  A sequence of *events* in process mining.

  Correspond to one instance of a certain *process*, for example:

  - an insurance claim which is processed in multiple steps at an insurance company
  - customer support ticket processing
  - conveyor belt manufacturing.

  Each event is represented as `DFM.Event` struct.
  """

  defstruct [:id, :events]

  @type t() :: %__MODULE__{
          id: any(),
          events: [DFM.Event.t()]
        }
end
