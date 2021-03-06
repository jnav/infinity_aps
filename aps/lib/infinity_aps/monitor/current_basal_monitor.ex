defmodule InfinityAPS.Monitor.CurrentBasalMonitor do
  @moduledoc false
  require Logger

  def loop do
    Logger.debug("Reading temp basal")

    case pump().read_temp_basal() do
      {:ok, temp_basal} -> write_oref0(temp_basal)
      response -> Logger.warn("Got: #{inspect(response)}")
    end
  end

  def write_oref0(temp_basal) do
    loop_dir = Path.expand(Application.get_env(:aps, :loop_directory))
    File.mkdir_p!(loop_dir)

    encoded =
      Poison.encode!(%{
        duration: temp_basal.duration,
        rate: temp_basal.units_per_hour,
        temp: temp_basal.type
      })

    File.write!("#{loop_dir}/temp_basal.json", encoded, [:binary])
  end

  defp pump do
    Application.get_env(:pummpcomm, :pump)
  end
end
