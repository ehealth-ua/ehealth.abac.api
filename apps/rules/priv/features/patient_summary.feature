@patient_summary
Feature: Patient summary

    Attribute based permissions for patient summary

    @create
    Scenario: Nobody can create patient summary
        When I require create access
        Then I can't create

    @read
    Scenario: Anyone can read patient summary
        When I require read access
        Then I can read

    @update
    Scenario: Nobody can update patient summary
        When I require update access
        Then I can't update

    @action
    Scenario: Nobody can do action to patient summary
        When I require action access
        Then I can't do action
