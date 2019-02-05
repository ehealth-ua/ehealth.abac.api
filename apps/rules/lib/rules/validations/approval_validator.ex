defmodule Rules.Validations.ApprovalValidator do
  @moduledoc false

  @rpc_worker Application.get_env(:rules, :rpc_worker)

  @doc "Not implemented"
  def active_approval?(_), do: false

  def active_approval?(patient_id, user_id, client_id, resource_id, "episode") do
    with {:ok, employee_ids} <-
           @rpc_worker.run("ehealth", Core.Rpc, :employees_by_user_id_client_id, [
             user_id,
             client_id
           ]),
         approvals <-
           @rpc_worker.run("medical_events_api", Api.Rpc, :approvals_by_episode, [
             patient_id,
             employee_ids,
             resource_id
           ]) do
      !Enum.empty?(approvals)
    end
  end

  def active_approval?(patient_id, user_id, client_id, resource_id, "encounter") do
    with {:ok, episode} <-
           @rpc_worker.run("medical_events_api", Api.Rpc, :episode_by_encounter_id, [
             patient_id,
             resource_id
           ]),
         {:ok, employee_ids} <-
           @rpc_worker.run("ehealth", Core.Rpc, :employees_by_user_id_client_id, [
             user_id,
             client_id
           ]),
         approvals <-
           @rpc_worker.run("medical_events_api", Api.Rpc, :approvals_by_episode, [
             patient_id,
             employee_ids,
             episode.id
           ]) do
      !Enum.empty?(approvals)
    end
  end

  def active_approval?(patient_id, user_id, client_id, resource_id, "observation") do
    with {:ok, episode} <-
           @rpc_worker.run("medical_events_api", Api.Rpc, :episode_by_observation_id, [
             patient_id,
             resource_id
           ]),
         {:ok, employee_ids} <-
           @rpc_worker.run("ehealth", Core.Rpc, :employees_by_user_id_client_id, [
             user_id,
             client_id
           ]),
         approvals <-
           @rpc_worker.run("medical_events_api", Api.Rpc, :approvals_by_episode, [
             patient_id,
             employee_ids,
             episode.id
           ]) do
      !Enum.empty?(approvals)
    end
  end

  def active_approval?(patient_id, user_id, client_id, resource_id, "condition") do
    with {:ok, episode} <-
           @rpc_worker.run("medical_events_api", Api.Rpc, :episode_by_condition_id, [
             patient_id,
             resource_id
           ]),
         {:ok, employee_ids} <-
           @rpc_worker.run("ehealth", Core.Rpc, :employees_by_user_id_client_id, [
             user_id,
             client_id
           ]),
         approvals <-
           @rpc_worker.run("medical_events_api", Api.Rpc, :approvals_by_episode, [
             patient_id,
             employee_ids,
             episode.id
           ]) do
      !Enum.empty?(approvals)
    end
  end

  def active_approval?(patient_id, user_id, client_id, resource_id, "allergy_intolerance") do
    with {:ok, episode} <-
           @rpc_worker.run("medical_events_api", Api.Rpc, :episode_by_allergy_intolerance_id, [
             patient_id,
             resource_id
           ]),
         {:ok, employee_ids} <-
           @rpc_worker.run("ehealth", Core.Rpc, :employees_by_user_id_client_id, [
             user_id,
             client_id
           ]),
         approvals <-
           @rpc_worker.run("medical_events_api", Api.Rpc, :approvals_by_episode, [
             patient_id,
             employee_ids,
             episode.id
           ]) do
      !Enum.empty?(approvals)
    end
  end

  def active_approval?(patient_id, user_id, client_id, resource_id, "immunization") do
    with {:ok, episode} <-
           @rpc_worker.run("medical_events_api", Api.Rpc, :episode_by_immunization_id, [
             patient_id,
             resource_id
           ]),
         {:ok, employee_ids} <-
           @rpc_worker.run("ehealth", Core.Rpc, :employees_by_user_id_client_id, [
             user_id,
             client_id
           ]),
         approvals <-
           @rpc_worker.run("medical_events_api", Api.Rpc, :approvals_by_episode, [
             patient_id,
             employee_ids,
             episode.id
           ]) do
      !Enum.empty?(approvals)
    end
  end

  @doc """
  TODO: not implemented
  """
  def active_approval?(_, _, _, _, _), do: false
end
