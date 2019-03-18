@medical_events
Feature: Medical events

    Attribute based permissions for medical events

    @rule_1 @read @episode @encounter @observation @condition @allergy_intolerance @immunization
    Scenario: Doctor with active declaration can read all patient data
        Given Active declaration with patient
        And declaration from the same MSP
        When I require read access
        Then I can read

    @rule_2 @read @episode
    Scenario: Doctor can read episode created in the doctors MSP
        Given Episode has been created on my MSP
        When I require read access
        Then I can read

    @rule_3 @read @encounter @observation @condition @allergy_intolerance @immunization @risk_assessment @device @medication_statement
    Scenario: Doctor can read all the data of episodes created in the doctors MSP
        Given Episode context has been created on my MSP
        When I require read access
        Then I can read

    @rule_4 @read @episode @encounter @observation @condition @allergy_intolerance @immunization @risk_assessment @device @medication_statement
    Scenario: Doctor with active approval can read all the data of specified in approval patient
        Given Active approval on patient
        When I require read access
        Then I can read

    @rule_5 @read @episode @encounter @observation @condition @allergy_intolerance @immunization @risk_assessment @device @medication_statement
    Scenario: Doctor with active approval can read all the data of specified in approval episodes
        Given Active approval on episode
        When I require read access
        Then I can read
