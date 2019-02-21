@medical_events
Feature: Medical events

    Attribute based permissions for medical events

    # 1
    @rule_1 @read @episode @encounter @observation @condition @allergy_intolerance @immunization
    Scenario: Doctor with active declaration can read all patient data
        Given Active declaration with patient
        #contexts.patient_id in consumer.employees[].declarations[].mpi_id
        And declaration from the same MSP
        #consumer.client_id = consumer.employees[].declarations[].legal_entity_id
        When I require read access
        Then I can read

    @rule_2 @read @episode @encounter @observation @condition @allergy_intolerance @immunization
    Scenario: Doctor with active approval can read all the data of specified in approval patient
        Given Active approval on patient
        #contexts.patient_id in consumer.employees[].approvals[].approved_objects[].mpi_id
        When I require read access
        Then I can read

    @rule_3 @read @episode @encounter @observation @condition @allergy_intolerance @immunization
    Scenario: Doctor with active approval can read all the data of specified in approval episodes
        Given Active approval on episode
        #contexts.episode_id in consumer.employees[].approvals[].approved_objects[].episode_id
        When I require read access
        Then I can read

    @rule_4 @read @episode @encounter @observation @condition @allergy_intolerance @immunization
    Scenario: Doctor can read all the data of episodes created in the doctors MSP
        Given Episode has been created on my MSP
        #contexts.resource.legal_entity_id = consumer.client_id
        When I require read access
        Then I can read
