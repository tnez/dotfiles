---
description: Review the current diff using a live Hunk session
---

# Review With Hunk

Load the Hunk skill and use it for this review. Run `hunk skill path` to get
the skill path.

If the skill tool can load that path directly, use it. Otherwise, read the file
at the printed path and follow its instructions.

Do not run interactive Hunk commands such as `hunk diff` yourself. Assume Travis
has a Hunk session open in another pane. If no live Hunk session is available,
ask Travis to start one with `hunk diff`.

Use Hunk's session CLI to inspect the diff, navigate to important hunks, and add
focused review comments when useful. Start with structure-only review output and
only include raw patch text when needed.

If $ARGUMENTS is non-empty, treat it as the review focus or additional review
instructions:

$ARGUMENTS
