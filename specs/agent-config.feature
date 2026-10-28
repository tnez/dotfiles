Feature: Materialized agent configuration
  Agent setup follows the declared end state instead of installing symlinks.
  Shared instructions and Pi preferences are local files; unrelated state survives.

  Scenario: Inspect setup without changing the machine
    Given agent configuration differs from the shared declaration
    When I request a configuration plan
    Then I see which instruction files and preference keys need changes
    And no local configuration is changed

  Scenario: Apply the reviewed end state
    Given I approved the declared preference changes
    And the primary checkout and host checks are healthy
    When I apply agent configuration
    Then shared instructions are regular files for home, Codex and Pi
    And Pi starts fresh sessions with Sol 6.1 at high reasoning
    And its quick model cycle is Astra, Luna and Sol 6.1 at high reasoning
    And declared navigation keybindings are available
    And unrelated settings, themes, credentials, sessions and skills survive
    And applying the same declaration again leaves matching files unchanged

  Scenario: Migrate known instruction and keybinding links
    Given local links resolve to this checkout's declared sources
    And I explicitly approved migration of those links
    When I apply agent configuration
    Then those links become regular local files
    And the repository sources are not changed by materialization
    And private recovery information is retained

  Scenario: Preserve unexpected or concurrently changed state
    Given configuration is malformed, redirected, or changed during review
    When I attempt to apply agent configuration
    Then setup stops with an actionable review requirement
    And unexpected local state is not deliberately overwritten
    And any partial operation is reported for recovery

  Scenario: Prime knowledge-base context
    Given the launching environment supplies the knowledge-base checkout
    When an agent prepares relevant operating context
    Then it reads the agent guide, bundle index and consumption contract
    And it selects task-relevant guidance with maturity signals preserved
    And it does not claim readable paths alone prove context was loaded
