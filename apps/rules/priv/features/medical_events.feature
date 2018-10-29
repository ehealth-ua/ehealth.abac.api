@medical_events
Feature: Medical events

    Attribute based permissions for medical events

    @read
    Scenario: Doctor with declaration from the same MSP can read patient data
        Given Active declaration with patient
        And MSP = MSP from request
        When I require read access
        Then I can read

    @write
    Scenario: Doctor with declaration from the same MSP can write patient data
        Given Active declaration with patient
        And MSP = MSP from request
        When I require write access
        Then I can write

    @update
    Scenario: Doctor with declaration from the same MSP can update patient data
        Given Active declaration with patient
        And MSP = MSP from request
        When I require update access
        Then I can update

    @action
    Scenario: Doctor with declaration from the same MSP can do action with patient data
        Given Active declaration with patient
        And MSP = MSP from request
        When I require action access
        Then I can do action

    @read
    Scenario: Doctor with declaration from the different MSP can't read patient data
        Given Active declaration with patient
        And MSP != MSP from request
        When I require read access
        Then I can't read

    @write
    Scenario: Doctor with declaration from the different MSP can write patient data
        Given Active declaration with patient
        And MSP != MSP from request
        When I require write access
        Then I can write

    @update
    Scenario: Doctor with declaration from the different MSP can't update patient data
        Given Active declaration with patient
        And MSP != MSP from request
        When I require update access
        Then I can't update

    @action
    Scenario: Doctor with declaration from the different MSP can't do action with patient data
        Given Active declaration with patient
        And MSP != MSP from request
        When I require action access
        Then I can't do action

    @read
    Scenario: Doctor without declaration from the same MSP and same care level can read patient data
        Given MSP = MSP from request
        And care level = care level from request
        When I require read access
        Then I can read

    @write
    Scenario: Doctor without declaration from the same MSP and same care level can write patient data
        Given MSP = MSP from request
        And care level = care level from request
        When I require write access
        Then I can write

    @update
    Scenario: Doctor without declaration from the same MSP and same care level can update patient data
        Given MSP = MSP from request
        And care level = care level from request
        When I require update access
        Then I can update

    @action
    Scenario: Doctor without declaration from the same MSP and same care level can do action with patient data
        Given MSP = MSP from request
        And care level = care level from request
        When I require action access
        Then I can do action
