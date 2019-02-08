defmodule Rules.Validations.MedicalEventsResourceValidator do
  @moduledoc false

  @rpc_worker Application.get_env(:rules, :rpc_worker)

  def same_msp_resource?(patient_id, client_id, nil, "episode", contexts) do
    with {:ok, episode} <- get_episode(patient_id, contexts) do
      episode.managing_organization.identifier.value == client_id
    end
  end

  def same_msp_resource?(patient_id, client_id, resource_id, "episode", _) do
    with {:ok, episode} <-
           @rpc_worker.run("medical_events_api", Api.Rpc, :episode_by_id, [
             patient_id,
             resource_id
           ]) do
      episode.managing_organization.identifier.value == client_id
    end
  end

  def same_msp_resource?(_, _, _, _, _), do: false

  defp get_episode(patient_id, contexts) do
    case Enum.find(contexts, &(Map.get(&1, "type") == "episode")) do
      nil ->
        nil

      %{"id" => id} ->
        with {:ok, episode} <-
               @rpc_worker.run("medical_events_api", Api.Rpc, :episode_by_id, [
                 patient_id,
                 id
               ]) do
          {:ok, episode}
        else
          _ -> nil
        end

      _ ->
        nil
    end
  end
end
