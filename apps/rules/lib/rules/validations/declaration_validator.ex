defmodule Rules.Validations.DeclarationValidator do
  @moduledoc false

  alias CasherProto.PersonDataRequest
  alias CasherProto.PersonDataResponse
  alias Rules.Redis
  alias Rules.Redis.StorageKeys

  @worker Application.fetch_env!(:rules, :worker)

  def has_active_declaration?(patient_id, user_id, client_id) do
    with {:ok, patient_ids} <- get_patient_ids(user_id, client_id) do
      patient_id in patient_ids
    end
  end

  defp get_patient_ids(user_id, client_id) do
    case Redis.get(StorageKeys.person_data(user_id, client_id)) do
      {:ok, patient_ids} ->
        {:ok, patient_ids}

      _ ->
        with {:ok, %PersonDataResponse{person_ids: patient_ids}} <-
               @worker.call(
                 CasherGrpc.Stub,
                 :person_data,
                 PersonDataRequest.new(user_id: user_id, client_id: client_id)
               ) do
          {:ok, patient_ids}
        end
    end
  end
end
