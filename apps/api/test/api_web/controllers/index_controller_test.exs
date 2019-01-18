defmodule ApiWeb.IndexControllerTest do
  @moduledoc false

  use ApiWeb.ConnCase

  setup :verify_on_exit!

  describe "check permissions" do
    test "invalid params", %{conn: conn} do
      response =
        conn
        |> post(index_path(conn, :authorize))
        |> json_response(422)

      assert %{
               "error" => %{
                 "invalid" => [
                   %{
                     "entry" => "$.consumer",
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
      patient_id = UUID.uuid4()
      client_id = UUID.uuid4()

      stub(RpcWorkerMock, :run, fn
        "casher", _, :get_person_data, _ -> {:ok, [patient_id]}
        "ehealth", _, :employees_by_user_id_client_id, _ -> {:ok, []}
        "ops", _, :declarations_by_employees, _ -> {:ok, [%{legal_entity_id: client_id}]}
      end)

      params = %{
        "consumer" => %{"user_id" => UUID.uuid4(), "client_id" => client_id, "client_type" => "MSP"},
        "resource" => %{"type" => "encounter", "id" => UUID.uuid4(), "action" => "read"},
        "contexts" => [%{"type" => "patient", "id" => patient_id}]
      }

      assert %{"data" => %{"result" => true}} =
               conn
               |> post(index_path(conn, :authorize), params)
               |> json_response(200)
    end
  end
end
