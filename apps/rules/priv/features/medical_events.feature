@medical_events
Feature: Medical events

    Attribute based permissions for medical events

    # 1
    @create
    Scenario: Doctor with declaration from the same MSP can create patient data
        Given Active declaration with patient
        And MSP = MSP from request
        When I require create access
        Then I can create

    @read
    Scenario: Doctor with declaration from the same MSP can read patient data
        Given Active declaration with patient
        And MSP = MSP from request
        When I require read access
        Then I can read

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

    # 2
    @create
    Scenario: Doctor with declaration from the different MSP can't create patient data
        Given Active declaration with patient
        And MSP != MSP from request
        When I require create access
        Then I can't create

    @read
    Scenario: Doctor with declaration from the different MSP can read patient data
        Given Active declaration with patient
        And MSP != MSP from request
        When I require read access
        Then I can read

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

    # 3
    @create
    Scenario: Doctor without declaration from the same MSP and same care level can create patient data
        Given MSP = MSP from request
        And care level = care level from request
        When I require create access
        Then I can create

    @read
    Scenario: Doctor without declaration from the same MSP and same care level can read patient data
        Given MSP = MSP from request
        And care level = care level from request
        When I require read access
        Then I can read

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

    # 4
    @create
    Scenario: Doctor without declaration from the same MSP and different care level can't create patient data
        Given MSP = MSP from request
        And care level != care level from request
        When I require create access
        Then I can't create

    @read
    Scenario: Doctor without declaration from the same MSP and different care level can read patient data
        Given MSP = MSP from request
        And care level != care level from request
        When I require read access
        Then I can read

    @update
    Scenario: Doctor without declaration from the same MSP and different care level can't update patient data
        Given MSP = MSP from request
        And care level != care level from request
        When I require update access
        Then I can't update

    @action
    Scenario: Doctor without declaration from the same MSP and different care level can't do action with patient data
        Given MSP = MSP from request
        And care level != care level from request
        When I require action access
        Then I can't do action

    # 5
    @create
    Scenario: Doctor without declaration from the different MSP and referral from the same MSP can't create patient data
        Given MSP != MSP from request
        And referral MSP = MSP from request
        When I require create access
        Then I can't create

    @read
    Scenario: Doctor without declaration from the different MSP and referral from the same MSP can read patient data
        Given MSP != MSP from request
        And referral MSP = MSP from request
        When I require read access
        Then I can read

    @update
    Scenario: Doctor without declaration from the different MSP and referral from the same MSP can't update patient data
        Given MSP != MSP from request
        And referral MSP = MSP from request
        When I require update access
        Then I can't update

    @action
    Scenario:  Doctor without declaration from the different MSP and referral from the same MSP can't update patient data
        Given MSP != MSP from request
        And referral MSP = MSP from request
        When I require action access
        Then I can't do action
