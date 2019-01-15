defmodule Rules.Validations.MedicalEventsResourceValidator do
  @moduledoc false

  @rpc_worker Application.get_env(:rules, :rpc_worker)

  def same_msp_resource?(client_id, "episode", resource_id, patient_id) do
    with {:ok, episode} <-
           @rpc_worker.run("medical_events_api", Api.Rpc, :episode_by_id, [
             patient_id,
             resource_id
           ]) do
      episode.care_manager.identifier.value == client_id
    end
  end

  def same_msp_resource?(_, _, _), do: false
end
