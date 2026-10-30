Feature: Acquire and retire activity workspaces through Scout
  Scout prepares a workspace, not the task itself.
  Each activity can use an independent clone without a permanent main checkout.
  The start-work and clean-up-work skills are shared through dotfiles on macOS
  and Omarchy, without taking ownership of unrelated installed skills.

  Scenario: Start a new activity
    Given I identify a repository and a short activity name
    And the repository has an origin/main branch
    When I ask Scout to open a workspace for that activity
    Then Scout creates an independent clone in an unused activity directory
    And the directory groups work by repository owner, repository, and activity
    And Scout creates an appropriately named branch from fresh origin/main
    And Scout follows documented repository branch-naming conventions
    And Scout opens a development session in that checkout
    And Scout reports the checkout, branch, base revision, and session

  Scenario: Keep startup lightweight
    When I ask Scout to prepare a workspace
    Then Scout does not require a task brief or implementation plan
    And Scout does not pass my task or conversation into the project session
    And Scout does not begin implementation
    And Scout does not run project bootstrap scripts, install dependencies,
      provision secrets, or grant project trust as part of opening the workspace

  Scenario: Resolve consequential ambiguity without guessing
    Given the repository identity, activity, or branch choice is ambiguous
    Or the intended origin/main branch is unavailable
    When I ask Scout to open a workspace
    Then Scout asks only for the unresolved choice needed to proceed
    And Scout does not silently substitute a remote or base branch
    And Scout does not overwrite an existing directory or reset local work

  Scenario: Resume existing work
    Given a checkout or published branch already matches the requested activity
    When I ask Scout to open that work
    Then Scout verifies its repository, branch, and local state
    And Scout resumes verified matching work instead of starting from main again
    And Scout does not repurpose a checkout belonging to another active worker
    And ambiguous matches require my choice

  Scenario: Use the available development layout from the popup
    Given I summon Scout from an attached tmux client
    When Scout opens an activity workspace
    Then Scout uses the installed dev launcher when it is suitable
    And otherwise Scout opens a simple tmux session in the checkout
    And Scout targets my verified originating client rather than its popup client
    And Scout leaves its persistent conversation and unrelated sessions intact
    And an ambiguous or vanished originating client is reported, not guessed

  Scenario: Recover from partial startup
    Given Scout has acquired a checkout but cannot finish opening its session
    When startup stops
    Then Scout reports what exists and what failed
    And Scout retains the checkout for inspection or a safe retry
    And Scout does not delete it or overwrite it to conceal the failure

  Scenario: Inspect before cleaning up
    When I ask Scout to clean up an activity workspace
    Then Scout verifies the exact checkout and associated session
    And Scout inspects staged, unstaged, untracked, and ignored state
    And Scout checks local branches, detached work, stashes, and running processes
    And Scout verifies a preservation destination for work that must survive
    And a clean git status alone is not sufficient evidence for deletion
    And Scout reports the proposed removal and obtains explicit approval

  Scenario: Preserve work that cannot safely be retired
    Given a workspace contains unpreserved work or uncertain local state
    When I ask Scout to clean it up
    Then Scout retains the workspace and explains the blocker
    And Scout does not implicitly push, publish, copy secrets, or discard work
    And intentional discard requires my explicit decision about the named state

  Scenario: Remove only the approved activity
    Given preservation checks pass and I approve the exact cleanup
    When Scout retires the activity
    Then Scout rechecks that the inspected state has not changed
    And Scout stops only the approved activity processes and session
    And Scout removes only the approved activity checkout
    And Scout leaves other workspaces, Scout history, and installed skills intact
    And checkouts backing live configuration links or configured knowledge-base
      paths are not treated as disposable activity checkouts
    And Scout verifies and reports the cleanup result

  Scenario: Install only the two shared skills after separate approval
    Given the skills have been reviewed in the canonical dotfiles checkout
    When I approve their installation on a supported machine
    Then only the start-work and clean-up-work skill entries are installed
    And existing foreign files or links are reported as conflicts
    And Dottie, Omarchy skills, agent settings, credentials, and history survive
    And preparing or validating the candidate does not activate it automatically
