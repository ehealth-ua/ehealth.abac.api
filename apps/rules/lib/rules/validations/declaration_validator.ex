defmodule Rules.Validations.DeclarationValidator do
  @moduledoc false

  alias Core.Redis
  alias Core.Redis.StorageKeys
  alias Rules.Rpc.Cache

  @rpc_worker Application.get_env(:rules, :rpc_worker)

  def has_active_declaration?(nil, _, _), do: false

  def has_active_declaration?(patient_id, user_id, client_id) do
    with {:ok, patient_ids} <- get_patient_ids(user_id, client_id) do
      patient_id in patient_ids
    end
  end

  def same_msp_declaration?(client_id, user_id) do
    with {:ok, employee_ids} <-
           Cache.run("ehealth", EHealth.Rpc, :employees_by_user_id_client_id, [
             user_id,
             client_id
           ]),
         declarations <-
           Cache.run("ops", OPS.Rpc, :declarations_by_employees, [
             employee_ids,
             [:legal_entity_id]
           ]) do
      client_id in Enum.map(declarations, &Map.get(&1, :legal_entity_id))
    else
      _ -> false
    end
  end

  defp get_patient_ids(user_id, client_id) do
    case Redis.get(StorageKeys.person_data(user_id, client_id)) do
      {:ok, patient_ids} ->
        {:ok, patient_ids}

      _ ->
        with {:ok, %{person_ids: patient_ids}} <-
               @rpc_worker.run("casher", Casher.Rpc, :get_person_data, [
                 %{"user_id" => user_id, "client_id" => client_id}
               ]) do
          {:ok, patient_ids}
        end
    end
  end
end
