defmodule Docker.Container do
  defstruct [:id, :status]

  defmodule Status do
    @allowed_states ~w(created running paused restarting removing exited dead)
    @type state :: :created | :running | :paused | :restarting | :removing | :exited | :dead

    defstruct [:state, :running]

    def parse_status(status_as_string) do
      case status_as_string in @allowed_states do
        true -> String.to_atom(status_as_string)
        false -> nil
      end
    end
  end

  def running?(container), do: container.status.running
end
