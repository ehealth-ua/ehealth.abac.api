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

  describe "list episodes" do
    test "no access @rule_2" do
      client_id = UUID.uuid4()

      refute DecisionManager.check_access(%{
               "resource" => %{"type" => "episode", "action" => "read", "id" => nil},
               "consumer" => %{
                 "user_id" => UUID.uuid4(),
                 "client_id" => client_id,
                 "client_type" => "MIS"
               },
               "contexts" => [
                 %{"type" => "managing_organization_id", "id" => UUID.uuid4()}
               ]
             })
    end

    test "success access @rule_2" do
      client_id = UUID.uuid4()

      assert DecisionManager.check_access(%{
               "resource" => %{"type" => "episode", "action" => "read", "id" => nil},
               "consumer" => %{
                 "user_id" => UUID.uuid4(),
                 "client_id" => client_id,
                 "client_type" => "MIS"
               },
               "contexts" => [
                 %{"type" => "managing_organization_id", "id" => client_id}
               ]
             })
    end
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

    test "success to access to encounter on active approval on episode" do
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

    test "success to access to observation on active approval on episode" do
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

        "medical_events_api", _, :episode_by_observation_id, _ ->
          {:ok, %{id: UUID.uuid4()}}
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

    test "success to access to condition on active approval on episode" do
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

        "medical_events_api", _, :episode_by_condition_id, _ ->
          {:ok, %{id: UUID.uuid4()}}
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

    test "success to access to allergy_intolerance on active approval on episode" do
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

    test "success to access to immunization on active approval on episode" do
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

        "medical_events_api", _, :episode_by_immunization_id, _ ->
          {:ok, %{id: UUID.uuid4()}}
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

    test "success to access to risk assessment on active approval on episode" do
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

        "medical_events_api", _, :episode_by_risk_assessment_id, _ ->
          {:ok, %{id: UUID.uuid4()}}
      end)

      assert DecisionManager.check_access(%{
               "resource" => %{
                 "type" => "risk_assessment",
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

    test "success to access to device on active approval on episode" do
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

        "medical_events_api", _, :episode_by_device_id, _ ->
          {:ok, %{id: UUID.uuid4()}}
      end)

      assert DecisionManager.check_access(%{
               "resource" => %{
                 "type" => "device",
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

    test "success to access to medication statement on active approval on episode" do
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

        "medical_events_api", _, :episode_by_medication_statement_id, _ ->
          {:ok, %{id: UUID.uuid4()}}
      end)

      assert DecisionManager.check_access(%{
               "resource" => %{
                 "type" => "medication_statement",
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

    test "success to access to service request on active approval on episode" do
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

        "medical_events_api", _, :episode_by_service_request_id, _ ->
          {:ok, %{id: UUID.uuid4()}}
      end)

      assert DecisionManager.check_access(%{
               "resource" => %{
                 "type" => "service_request",
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

    test "success to access to service request in the same MSP" do
      patient_id = UUID.uuid4()
      client_id = UUID.uuid4()
      employee_ids = [UUID.uuid4()]

      stub(RpcWorkerMock, :run, fn
        "ops", _, :declarations_by_employees, _ ->
          []

        "ehealth", _, :employees_by_user_id_client_id, _ ->
          {:ok, employee_ids}

        "medical_events_api", _, :episode_by_service_request_id, _ ->
          nil

        "medical_events_api", _, :service_request_by_id, _ ->
          {:ok, %{requester_legal_entity: %{identifier: %{value: client_id}}}}
      end)

      assert DecisionManager.check_access(%{
               "resource" => %{
                 "type" => "service_request",
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

    test "success to access to diagnostic report on active approval on episode" do
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

        "medical_events_api", _, :episode_by_diagnostic_report_id, _ ->
          {:ok, %{id: UUID.uuid4()}}
      end)

      assert DecisionManager.check_access(%{
               "resource" => %{
                 "type" => "diagnostic_report",
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

    test "success to access to diagnostic report in the same MSP" do
      patient_id = UUID.uuid4()
      client_id = UUID.uuid4()
      employee_ids = [UUID.uuid4()]

      stub(RpcWorkerMock, :run, fn
        "ops", _, :declarations_by_employees, _ ->
          []

        "ehealth", _, :employees_by_user_id_client_id, _ ->
          {:ok, employee_ids}

        "medical_events_api", _, :episode_by_diagnostic_report_id, _ ->
          nil

        "medical_events_api", _, :diagnostic_report_by_id, _ ->
          {:ok, %{managing_organization: %{identifier: %{value: client_id}}}}
      end)

      assert DecisionManager.check_access(%{
               "resource" => %{
                 "type" => "diagnostic_report",
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

    test "success to access to diagnostic report originated by mine episode" do
      patient_id = UUID.uuid4()
      client_id = UUID.uuid4()
      employee_ids = [UUID.uuid4()]
      origin_episode_id = UUID.uuid4()

      stub(RpcWorkerMock, :run, fn
        "ops", _, :declarations_by_employees, _ ->
          []

        "ehealth", _, :employees_by_user_id_client_id, _ ->
          {:ok, employee_ids}

        "medical_events_api", _, :episode_by_diagnostic_report_id, _ ->
          nil

        "medical_events_api", _, :diagnostic_report_by_id, _ ->
          {:ok, %{origin_episode: %{identifier: %{value: origin_episode_id}}}}

        "medical_events_api", _, :episode_by_id, _ ->
          {:ok, %{managing_organization: %{identifier: %{value: client_id}}}}
      end)

      assert DecisionManager.check_access(%{
               "resource" => %{
                 "type" => "diagnostic_report",
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
