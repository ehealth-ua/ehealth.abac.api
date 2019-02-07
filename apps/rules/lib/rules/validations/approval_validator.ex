defmodule Rules.Validations.ApprovalValidator do
  @moduledoc false

  @rpc_worker Application.get_env(:rules, :rpc_worker)

  @doc "Not implemented"
  def active_approval?(_), do: false

  def active_approval?(patient_id, user_id, client_id, nil, _, contexts) do
    with {:ok, episode_id} <- get_episode_id(contexts),
         {:ok, approvals} <- get_approvals(patient_id, user_id, client_id, episode_id) do
      !Enum.empty?(approvals)
    end
  end

  def active_approval?(patient_id, user_id, client_id, resource_id, "episode", _) do
    with {:ok, approvals} <- get_approvals(patient_id, user_id, client_id, resource_id) do
      !Enum.empty?(approvals)
    end
  end

  def active_approval?(patient_id, user_id, client_id, resource_id, "encounter", contexts) do
    with {:ok, episode_id} <- get_episode_id(contexts, patient_id, resource_id, :episode_by_encounter_id),
         {:ok, approvals} <- get_approvals(patient_id, user_id, client_id, episode_id) do
      !Enum.empty?(approvals)
    end
  end

  def active_approval?(patient_id, user_id, client_id, resource_id, "observation", contexts) do
    with {:ok, episode_id} <- get_episode_id(contexts, patient_id, resource_id, :episode_by_observation_id),
         {:ok, approvals} <- get_approvals(patient_id, user_id, client_id, episode_id) do
      !Enum.empty?(approvals)
    end
  end

  def active_approval?(patient_id, user_id, client_id, resource_id, "condition", contexts) do
    with {:ok, episode_id} <- get_episode_id(contexts, patient_id, resource_id, :episode_by_condition_id),
         {:ok, approvals} <- get_approvals(patient_id, user_id, client_id, episode_id) do
      !Enum.empty?(approvals)
    end
  end

  def active_approval?(
        patient_id,
        user_id,
        client_id,
        resource_id,
        "allergy_intolerance",
        contexts
      ) do
    with {:ok, episode_id} <- get_episode_id(contexts, patient_id, resource_id, :episode_by_allergy_intolerance_id),
         {:ok, approvals} <- get_approvals(patient_id, user_id, client_id, episode_id) do
      !Enum.empty?(approvals)
    end
  end

  def active_approval?(patient_id, user_id, client_id, resource_id, "immunization", contexts) do
    with {:ok, episode_id} <- get_episode_id(contexts, patient_id, resource_id, :episode_by_immunization_id),
         {:ok, approvals} <- get_approvals(patient_id, user_id, client_id, episode_id) do
      !Enum.empty?(approvals)
    end
  end

  @doc """
  TODO: not implemented
  """
  def active_approval?(_, _, _, _, _), do: false

  defp get_episode_id(contexts) do
    case Enum.find(contexts, &(Map.get(&1, "type") == "episode")) do
      nil ->
        nil

      %{"id" => id} ->
        {:ok, id}

      _ ->
        nil
    end
  end

  defp get_episode_id(contexts, patient_id, resource_id, rpc_fun) do
    case Enum.find(contexts, &(Map.get(&1, "type") == "episode")) do
      nil ->
        with {:ok, episode} <-
               @rpc_worker.run("medical_events_api", Api.Rpc, rpc_fun, [
                 patient_id,
                 resource_id
               ]) do
          {:ok, episode.id}
        else
          _ -> nil
        end

      %{"id" => id} ->
        {:ok, id}

      _ ->
        nil
    end
  end

  defp get_approvals(patient_id, user_id, client_id, episode_id) do
    with {:ok, employee_ids} <-
           @rpc_worker.run("ehealth", Core.Rpc, :employees_by_user_id_client_id, [
             user_id,
             client_id
           ]) do
      case @rpc_worker.run("medical_events_api", Api.Rpc, :approvals_by_episode, [
             patient_id,
             employee_ids,
             episode_id
           ]) do
        approvals when is_list(approvals) -> {:ok, approvals}
        _ -> nil
      end
    end
  end
end