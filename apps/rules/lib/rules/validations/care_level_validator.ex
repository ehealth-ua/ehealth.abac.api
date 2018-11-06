defmodule Rules.Validations.CareLevelValidator do
  @moduledoc false

  alias EHealthProto.EmployeesRequest
  alias EHealthProto.EmployeesResponse
  alias EHealthProto.EmployeesResponse.Employee
  alias EHealthProto.PartyUserRequest
  alias EHealthProto.PartyUserResponse
  alias EHealthProto.PartyUserResponse.PartyUser

  @worker Application.fetch_env!(:rules, :worker)

  @doc """
  TODO: implement resource care level search
  """
  def care_level_from_request(_patient_id, user_id, client_id) do
    true
    # with {:ok, %PartyUserResponse{party_user: %PartyUser{party_id: party_id}}} <-
    #        @worker.call(EHealthGrpc.Stub, :party_user, PartyUserRequest.new(user_id: user_id)),
    #      {:ok, %EmployeesResponse{employees: employees}} <-
    #        @worker.call(
    #          EHealthGrpc.Stub,
    #          :employees_speciality,
    #          EmployeesRequest.new(
    #            party_id: party_id,
    #            legal_entity_id: client_id
    #          )
    #        ) do
    #   request_care_levels =
    #     Enum.reduce(employees, MapSet.new(), fn %Employee{} = employee, acc ->
    #       MapSet.put(acc, get_care_level(employee.speciality.speciality))
    #     end)

    #   true
    # end
  end

  defp get_care_level(speciality) when speciality in ~w(PEDIATRICIAN THERAPIST FAMILY_DOCTOR),
    do: 1

  @doc """
  For now should always return :error
  """
  def care_level_not_from_request(_patient_id, _user_id, _client_id) do
    true
  end
end
