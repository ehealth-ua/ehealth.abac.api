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

  def active_approval?(patient_id, user_id, client_id, _, "encounter", contexts) do
    with {:ok, episode_id} <- get_episode_id(contexts),
         {:ok, approvals} <- get_approvals(patient_id, user_id, client_id, episode_id) do
      !Enum.empty?(approvals)
    end
  end

  def active_approval?(patient_id, user_id, client_id, _, "observation", contexts) do
    with {:ok, episode_id} <- get_episode_id(contexts),
         {:ok, approvals} <- get_approvals(patient_id, user_id, client_id, episode_id) do
      !Enum.empty?(approvals)
    end
  end

  def active_approval?(patient_id, user_id, client_id, _, "condition", contexts) do
    with {:ok, episode_id} <- get_episode_id(contexts),
         {:ok, approvals} <- get_approvals(patient_id, user_id, client_id, episode_id) do
      !Enum.empty?(approvals)
    end
  end

  def active_approval?(patient_id, user_id, client_id, _, "allergy_intolerance", contexts) do
    with {:ok, episode_id} <- get_episode_id(contexts),
         {:ok, approvals} <- get_approvals(patient_id, user_id, client_id, episode_id) do
      !Enum.empty?(approvals)
    end
  end

  def active_approval?(patient_id, user_id, client_id, _, "immunization", contexts) do
    with {:ok, episode_id} <- get_episode_id(contexts),
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
