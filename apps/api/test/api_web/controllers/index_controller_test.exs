defmodule ApiWeb.IndexControllerTest do
  @moduledoc false

  use ApiWeb.ConnCase
  alias EHealthProto.EmployeesResponse
  alias EHealthProto.EmployeesResponse.Employee
  alias EHealthProto.PartyUserResponse
  alias EHealthProto.PartyUserResponse.PartyUser

  setup :verify_on_exit!

  describe "check permissions" do
    test "invalid params", %{conn: conn} do
      response =
        conn
        |> post(index_path(conn, :check))
        |> json_response(422)

      assert %{
               "error" => %{
                 "invalid" => [
                   %{
                     "entry" => "$.consumer",
                     "rules" => [%{"rule" => "required"}]
                   },
                   %{
                     "entry" => "$.action",
                     "rules" => [%{"rule" => "required"}]
                   },
                   %{
                     "entry" => "$.resource",
                     "rules" => [%{"rule" => "required"}]
                   }
                 ]
               }
             } = response
    end

    test "success", %{conn: conn} do
      expect(WorkerMock, :call, fn _, :party_user, _ ->
        {:ok, %PartyUserResponse{party_user: %PartyUser{party_id: UUID.uuid4()}}}
      end)

      expect(WorkerMock, :call, fn _, :employees_speciality, _ ->
        {:ok, %EmployeesResponse{employees: [%Employee{speciality: %{speciality: "THERAPIST"}}]}}
      end)

      params = %{
        "consumer" => %{"user_id" => UUID.uuid4(), "client_id" => UUID.uuid4(), "client_type" => "MSP"},
        "action" => "read",
        "resource" => %{"resource" => %{"type" => "encounter", "id" => UUID.uuid4()}}
      }

      assert %{"data" => %{"result" => true}} =
               conn
               |> post(index_path(conn, :check), params)
               |> json_response(200)
    end
  end
end
