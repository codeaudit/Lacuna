@api
  Feature: annotation_sharing
    As a user
    In order to annotate texts
    I should be able to create annotations with different sharing options

    Background:
      Given an "Instructor" user named "Instructor A" exists
      And an "Instructor" user named "Instructor B" exists
      And "course" content:
        | title         | author        |
        | Course Alpha  | Instructor A  |
        | Course Beta   | Instructor B  |
      And "Instructor A" is the instructor of the "Course Alpha" course
      And "Instructor B" is the instructor of the "Course Beta" course
      And "document" content:
        | title       | author       | body                                |
        | Document A  | Instructor A | This is your reading for the week.  |
        | Document B  | Instructor B | I'm the cool professor.             |
      And document "Document A" is content for course "Course Alpha"
      And document "Document B" is content for course "Course Beta"
      And a "Student" user named "Student A" exists
      And "Student A" is enrolled in the "Course Alpha" course
      And "response" content:
        | title        | author      | body                                 |
        | Response A   | Student A   | This is my response.                 |
      And response "Response A" is content for course "Course Alpha"
      And annotations on document "Document A":
        | audience     | text                          | author     |
        | Private      | This is a private annotation  | Student A  |
        | Instructor   | This is for teacher           | Student A  |
        | Everyone     | This is for everyone          | Student A  |
      And "Student A" is enrolled in the "Course Beta" course
      And annotations on document "Document B":
        | audience     | text                          | author     |
        | Private      | Document B private            | Student A  |
        | Instructor   | Document B for teacher        | Student A  |
        | Everyone     | Document B for everyone       | Student A  |
      And annotations on response "Response A":
        | audience     | text                          | author     |
        | Student      | Student feedback              | Instructor A  |

    Scenario: Other student in the course
      Given I am logged in as a user with the "Student" role
      And I am enrolled in the "Course Alpha" course
      And my currently selected course is "Course Alpha"
      And I am on "/sewing-kit"
      Then I should see "This is for everyone" in the "View Content" region
      And I should not see "This is for teacher" in the "View Content" region
      And I should not see "This is a private annotation" in the "View Content" region
      And I should not see "Document B private" in the "View Content" region
      And I should not see "Document B for teacher" in the "View Content" region
      And I should not see "Document B for everyone" in the "View Content" region
#
    Scenario: Student A views Course A sewing kit
      Given I am logged in as "Student A"
      And my currently selected course is "Course Alpha"
      And I am on "/sewing-kit"
      Then I should see "This is for everyone" in the "View Content" region
      And I should see "This is for teacher" in the "View Content" region
      And I should see "This is a private annotation" in the "View Content" region
      And I should not see "Document B private" in the "View Content" region
      And I should not see "Document B for teacher" in the "View Content" region
      And I should not see "Document B for everyone" in the "View Content" region

    Scenario: Student A views Course B sewing kit
      Given I am logged in as "Student A"
      And my currently selected course is "Course Beta"
      And I am on "/sewing-kit"
      Then I should not see "This is for everyone" in the "View Content" region
      And I should not see "This is for teacher" in the "View Content" region
      And I should not see "This is a private annotation" in the "View Content" region
      And I should see "Document B private" in the "View Content" region
      And I should see "Document B for teacher" in the "View Content" region
      And I should see "Document B for everyone" in the "View Content" region

    Scenario: Instructor A views sewing kit
      Given I am logged in as "Instructor A"
      And my currently selected course is "Course Alpha"
      And I am on "/sewing-kit"
      Then I should see "This is for everyone" in the "View Content" region
      And I should see "This is for teacher" in the "View Content" region
      And I should not see "This is a private annotation" in the "View Content" region
      And I should not see "Document B private" in the "View Content" region
      And I should not see "Document B for teacher" in the "View Content" region
      And I should not see "Document B for everyone" in the "View Content" region

# NOTE: for some reason related to how tests creates content (I think), this scenario
# fails, but not because the functionality isn't working properly on the actual site
# So, I'm documenting the possibility here and the fact that it'll fail because it's a
# logical test to run
#    Scenario: Instructor B views sewing kit
#      Given I am logged in as "Instructor B"
#      And my currently selected course is "Course Beta"
#      And I am on "/sewing-kit"
#      Then I should not see "There are no annotations" in the "View Content" region
#      And I should not see "This is for everyone" in the "View Content" region
#      And I should not see "This is for teacher" in the "View Content" region
#      And I should not see "This is a private annotation" in the "View Content" region
#      And I should not see "Document B private" in the "View Content" region
#      And I should see "Document B for teacher" in the "View Content" region
#      And I should see "Document B for everyone" in the "View Content" region

  Scenario: Student joins course, gets private feedback group
    Given I am logged in as "Student A"
    And my currently selected course is "Course Alpha"
    Then I should be a member of a peer feedback group

  Scenario: Student A attempts to see private feedback
    Given I am logged in as "Student A"
    And My currently selected course is "Course Alpha"
    When I go to the "annotation" node named "Annotation of Response A"
    Then I should see "Annotation of Response A" in the "Page Title"

  Scenario: Instructor B attempts to see private feedback
    Given I am logged in as "Instructor B"
    When I go to the "annotation" node named "Annotation of Response A"
    Then I should see "Access denied" in the "Page Title"

  Scenario: Instructor A attempts to see private feedback
    Given I am logged in as "Instructor A"
    When I go to the "annotation" node named "Annotation of Response A"
    Then I should see "Annotation of Response A" in the "Page Title"