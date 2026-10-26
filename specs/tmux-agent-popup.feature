Feature: A shared Pi concierge in tmux
  The concierge sits above project-specific sessions and agents.
  Its conversation persists until I choose to start a new one.

  Scenario: Summon and hide the concierge
    Given I am using any normal tmux session
    When I press prefix followed by a
    Then Pi appears in a centered floating popup titled Scout
    When I press prefix followed by a inside the popup
    Then the popup closes without stopping Pi or interrupting its work
    And my original tmux session and pane remain selected

  Scenario: Continue the same conversation from another session
    Given I have hidden the concierge
    When I summon it from another tmux session on the same server
    Then I return to the same Pi process and conversation
    And it does not start another project-specific agent

  Scenario: Reset deliberately
    Given the concierge is visible
    When I run Pi's /new command
    Then Pi starts a new conversation using its normal behavior
    And hiding and reopening the popup preserves that conversation

  Scenario: Interpret where I summoned it from
    When I summon the concierge
    Then its working directory is my home rather than the invoking project
    And the latest invoking tmux context is available for Pi to query
    And it identifies the client, session, window, pane and directory
    And Pi is primed to query it before interpreting a tmux-relative request
    And no pane output is automatically collected
    And inspecting other sessions does not grant permission to control them
