@referrals
Feature: Referrals

    Attribute based permissions for referrals

    # 1
    @create
    Scenario: Doctor from the same MSP and same care level can create referral
        Given MSP = MSP from request
        And care level = care level from request
        When I require create access
        Then I can create

    @read
    Scenario: Doctor from the same MSP and same care level can read referral
        Given MSP = MSP from request
        And care level = care level from request
        When I require read access
        Then I can read

    @update
    Scenario: Doctor from the same MSP and same care level can't update referral
        Given MSP = MSP from request
        And care level = care level from request
        When I require update access
        Then I can't update

    @action
    Scenario: Doctor from the same MSP and same care level can do action referral
        Given MSP = MSP from request
        And care level = care level from request
        When I require action access
        Then I can do action

    # 2
    @create
    Scenario: Doctor from the same MSP and different care level can't create referral
        Given MSP = MSP from request
        And care level != care level from request
        When I require create access
        Then I can't create

    @read
    Scenario: Doctor from the same MSP and different care level can read referral
        Given MSP = MSP from request
        And care level != care level from request
        When I require read access
        Then I can read

    @update
    Scenario: Doctor from the same MSP and different care level can't update referral
        Given MSP = MSP from request
        And care level != care level from request
        When I require update access
        Then I can't update

    @action
    Scenario: Doctor from the same MSP and different care level can do action referral
        Given MSP = MSP from request
        And care level != care level from request
        When I require action access
        Then I can do action

    # 3
    @create
    Scenario: Doctor from the different MSP can't create referral
        Given MSP != MSP from request
        And care level != care level from request
        When I require create access
        Then I can't create

    @read
    Scenario: Doctor from the different MSP can read referral
        Given MSP != MSP from request
        And care level != care level from request
        When I require read access
        Then I can read

    @update
    Scenario: Doctor from the different MSP can't update referral
        Given MSP != MSP from request
        And care level != care level from request
        When I require update access
        Then I can't update

    @action
    Scenario: Doctor from the different MSP can't do action referral
        Given MSP != MSP from request
        And care level != care level from request
        When I require action access
        Then I can't do action
