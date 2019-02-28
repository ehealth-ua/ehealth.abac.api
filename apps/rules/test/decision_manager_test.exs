defmodule Rules.DecisionManagerTest do
  @moduledoc false

  use ExUnit.Case, async: true
  alias Rules.DecisionManager
  import Mox

  setup :verify_on_exit!

  setup do
    expect(KafkaMock, :publish_log, fn _ -> :ok end)
    :ok
  end

  describe "read episode" do
    test "no access" do
      refute DecisionManager.check_access(%{
               "resource" => %{"type" => "episode", "action" => "read"}
             })
    end

    test "success on active declaration" do
      patient_id = UUID.uuid4()
      client_id = UUID.uuid4()
      employee_ids = [UUID.uuid4()]
      declarations = [%{legal_entity_id: client_id}]

      stub(RpcWorkerMock, :run, fn
        "casher", _, :get_person_data, _ ->
          {:ok, %{person_ids: [patient_id]}}

        "ehealth", _, :employees_by_user_id_client_id, _ ->
          {:ok, employee_ids}

        "ops", _, :declarations_by_employees, _ ->
          declarations
      end)

      assert DecisionManager.check_access(%{
               "resource" => %{"type" => "episode", "action" => "read", "id" => UUID.uuid4()},
               "consumer" => %{
                 "user_id" => UUID.uuid4(),
                 "client_id" => client_id,
                 "client_type" => "MIS"
               },
               "contexts" => [
                 %{"type" => "patient", "id" => patient_id}
               ]
             })
    end

    test "success access to episode on active approval on episode" do
      patient_id = UUID.uuid4()
      client_id = UUID.uuid4()
      employee_ids = [UUID.uuid4()]

      stub(RpcWorkerMock, :run, fn
        "ops", _, :declarations_by_employees, _ ->
          []

        "ehealth", _, :employees_by_user_id_client_id, _ ->
          {:ok, employee_ids}

        "medical_events_api", _, :approvals_by_episode, _ ->
          [%{}]
      end)

      assert DecisionManager.check_access(%{
               "resource" => %{"type" => "episode", "action" => "read", "id" => UUID.uuid4()},
               "consumer" => %{
                 "user_id" => UUID.uuid4(),
                 "client_id" => client_id,
                 "client_type" => "MIS"
               },
               "contexts" => [
                 %{"type" => "patient", "id" => patient_id}
               ]
             })
    end

    test "success on same MSP episode context" do
      patient_id = UUID.uuid4()
      client_id = UUID.uuid4()

      stub(RpcWorkerMock, :run, fn
        "medical_events_api", _, :episode_by_id, _ ->
          {:ok, %{managing_organization: %{identifier: %{value: client_id}}}}

        "ops", _, :declarations_by_employees, _ ->
          []
      end)

      assert DecisionManager.check_access(%{
               "resource" => %{"type" => "encounter", "action" => "read", "id" => UUID.uuid4()},
               "consumer" => %{
                 "user_id" => UUID.uuid4(),
                 "client_id" => client_id,
                 "client_type" => "MIS"
               },
               "contexts" => [
                 %{"type" => "patient", "id" => patient_id},
                 %{"type" => "episode", "id" => UUID.uuid4()}
               ]
             })
    end

    test "success access to encounter on active approval on episode" do
      patient_id = UUID.uuid4()
      client_id = UUID.uuid4()
      employee_ids = [UUID.uuid4()]

      stub(RpcWorkerMock, :run, fn
        "ops", _, :declarations_by_employees, _ ->
          []

        "ehealth", _, :employees_by_user_id_client_id, _ ->
          {:ok, employee_ids}

        "medical_events_api", _, :episode_by_encounter_id, _ ->
          {:ok, %{id: UUID.uuid4()}}

        "medical_events_api", _, :approvals_by_episode, _ ->
          [%{}]
      end)

      assert DecisionManager.check_access(%{
               "resource" => %{"type" => "encounter", "action" => "read", "id" => UUID.uuid4()},
               "consumer" => %{
                 "user_id" => UUID.uuid4(),
                 "client_id" => client_id,
                 "client_type" => "MIS"
               },
               "contexts" => [
                 %{"type" => "patient", "id" => patient_id}
               ]
             })
    end

    test "success access to observation on active approval on episode" do
      patient_id = UUID.uuid4()
      client_id = UUID.uuid4()
      employee_ids = [UUID.uuid4()]

      stub(RpcWorkerMock, :run, fn
        "ops", _, :declarations_by_employees, _ ->
          []

        "ehealth", _, :employees_by_user_id_client_id, _ ->
          {:ok, employee_ids}

        "medical_events_api", _, :episode_by_observation_id, _ ->
          {:ok, %{id: UUID.uuid4()}}

        "medical_events_api", _, :approvals_by_episode, _ ->
          [%{}]
      end)

      assert DecisionManager.check_access(%{
               "resource" => %{"type" => "observation", "action" => "read", "id" => UUID.uuid4()},
               "consumer" => %{
                 "user_id" => UUID.uuid4(),
                 "client_id" => client_id,
                 "client_type" => "MIS"
               },
               "contexts" => [
                 %{"type" => "patient", "id" => patient_id}
               ]
             })
    end

    test "success access to condition on active approval on episode" do
      patient_id = UUID.uuid4()
      client_id = UUID.uuid4()
      employee_ids = [UUID.uuid4()]

      stub(RpcWorkerMock, :run, fn
        "ops", _, :declarations_by_employees, _ ->
          []

        "ehealth", _, :employees_by_user_id_client_id, _ ->
          {:ok, employee_ids}

        "medical_events_api", _, :episode_by_condition_id, _ ->
          {:ok, %{id: UUID.uuid4()}}

        "medical_events_api", _, :approvals_by_episode, _ ->
          [%{}]
      end)

      assert DecisionManager.check_access(%{
               "resource" => %{"type" => "condition", "action" => "read", "id" => UUID.uuid4()},
               "consumer" => %{
                 "user_id" => UUID.uuid4(),
                 "client_id" => client_id,
                 "client_type" => "MIS"
               },
               "contexts" => [
                 %{"type" => "patient", "id" => patient_id}
               ]
             })
    end

    test "success access to allergy_intolerance on active approval on episode" do
      patient_id = UUID.uuid4()
      client_id = UUID.uuid4()
      employee_ids = [UUID.uuid4()]

      stub(RpcWorkerMock, :run, fn
        "ops", _, :declarations_by_employees, _ ->
          []

        "ehealth", _, :employees_by_user_id_client_id, _ ->
          {:ok, employee_ids}

        "medical_events_api", _, :episode_by_allergy_intolerance_id, _ ->
          {:ok, %{id: UUID.uuid4()}}

        "medical_events_api", _, :approvals_by_episode, _ ->
          [%{}]
      end)

      assert DecisionManager.check_access(%{
               "resource" => %{
                 "type" => "allergy_intolerance",
                 "action" => "read",
                 "id" => UUID.uuid4()
               },
               "consumer" => %{
                 "user_id" => UUID.uuid4(),
                 "client_id" => client_id,
                 "client_type" => "MIS"
               },
               "contexts" => [
                 %{"type" => "patient", "id" => patient_id}
               ]
             })
    end

    test "success access to immunization on active approval on episode" do
      patient_id = UUID.uuid4()
      client_id = UUID.uuid4()
      employee_ids = [UUID.uuid4()]

      stub(RpcWorkerMock, :run, fn
        "ops", _, :declarations_by_employees, _ ->
          []

        "ehealth", _, :employees_by_user_id_client_id, _ ->
          {:ok, employee_ids}

        "medical_events_api", _, :episode_by_immunization_id, _ ->
          {:ok, %{id: UUID.uuid4()}}

        "medical_events_api", _, :approvals_by_episode, _ ->
          [%{}]
      end)

      assert DecisionManager.check_access(%{
               "resource" => %{
                 "type" => "immunization",
                 "action" => "read",
                 "id" => UUID.uuid4()
               },
               "consumer" => %{
                 "user_id" => UUID.uuid4(),
                 "client_id" => client_id,
                 "client_type" => "MIS"
               },
               "contexts" => [
                 %{"type" => "patient", "id" => patient_id}
               ]
             })
    end

    test "success on episode, created on my MSP" do
      patient_id = UUID.uuid4()
      client_id = UUID.uuid4()

      stub(RpcWorkerMock, :run, fn
        "medical_events_api", _, :episode_by_id, _ ->
          {:ok, %{managing_organization: %{identifier: %{value: client_id}}}}
      end)

      assert DecisionManager.check_access(%{
               "resource" => %{"type" => "episode", "action" => "read", "id" => UUID.uuid4()},
               "consumer" => %{
                 "user_id" => UUID.uuid4(),
                 "client_id" => client_id,
                 "client_type" => "MIS"
               },
               "contexts" => [
                 %{"type" => "patient", "id" => patient_id}
               ]
             })
    end
  end

  describe "read encounters" do
    test "success read encounters with active declaration" do
      patient_id = UUID.uuid4()
      client_id = UUID.uuid4()
      employee_ids = [UUID.uuid4()]
      declarations = [%{legal_entity_id: client_id}]

      stub(RpcWorkerMock, :run, fn
        "casher", _, :get_person_data, _ ->
          {:ok, %{person_ids: [patient_id]}}

        "ehealth", _, :employees_by_user_id_client_id, _ ->
          {:ok, employee_ids}

        "ops", _, :declarations_by_employees, _ ->
          declarations
      end)

      assert DecisionManager.check_access(%{
               "resource" => %{"type" => "encounter", "action" => "read"},
               "consumer" => %{
                 "user_id" => UUID.uuid4(),
                 "client_id" => client_id,
                 "client_type" => "MIS"
               },
               "contexts" => [
                 %{"type" => "patient", "id" => patient_id}
               ]
             })
    end

    test "no access to read encounters without episode context" do
      patient_id = UUID.uuid4()
      client_id = UUID.uuid4()
      employee_ids = [UUID.uuid4()]

      stub(RpcWorkerMock, :run, fn
        "ehealth", _, :employees_by_user_id_client_id, _ ->
          {:ok, employee_ids}

        "ops", _, :declarations_by_employees, _ ->
          []
      end)

      refute DecisionManager.check_access(%{
               "resource" => %{"type" => "encounter", "action" => "read"},
               "consumer" => %{
                 "user_id" => UUID.uuid4(),
                 "client_id" => client_id,
                 "client_type" => "MIS"
               },
               "contexts" => [
                 %{"type" => "patient", "id" => patient_id}
               ]
             })
    end

    test "success read encounters with active approval on episode" do
      patient_id = UUID.uuid4()
      client_id = UUID.uuid4()
      employee_ids = [UUID.uuid4()]

      stub(RpcWorkerMock, :run, fn
        "medical_events_api", _, :approvals_by_episode, _ ->
          [%{}]

        "ehealth", _, :employees_by_user_id_client_id, _ ->
          {:ok, employee_ids}

        "ops", _, :declarations_by_employees, _ ->
          []
      end)

      assert DecisionManager.check_access(%{
               "resource" => %{"type" => "encounter", "action" => "read"},
               "consumer" => %{
                 "user_id" => UUID.uuid4(),
                 "client_id" => client_id,
                 "client_type" => "MIS"
               },
               "contexts" => [
                 %{"type" => "patient", "id" => patient_id},
                 %{"type" => "episode", "id" => UUID.uuid4()}
               ]
             })
    end
  end
end
