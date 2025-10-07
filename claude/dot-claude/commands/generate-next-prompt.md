---
description: Generate continuation prompt for fresh context window
---

You have been working on something and have built up context through this conversation. The user is approaching their context window limit and needs you to generate a comprehensive prompt that they can paste into a fresh Claude Code session to continue the work seamlessly.

**Your task:**

Review the conversation history, current work state, and any pending tasks. Generate the most effective continuation prompt you can - one that captures everything the next Claude instance needs to pick up exactly where you left off.

**Critical considerations:**

- What was the main objective and what progress has been made?
- What files have been modified and why?
- Are there pending commits, reviews, or validations?
- What are the immediate next steps?
- What key decisions, patterns, or constraints were discovered that must be preserved?
- **Important: If there are any ongoing threads of thought or partially explored ideas that shouldn't be lost, explicitly call them out for continuation**

**Output format:**

Generate the prompt in whatever structure you think will be most effective for the next instance. Then pipe it to `pbcopy` so the user can paste it into a fresh session.

Your goal is to minimize context loss and ensure the next Claude can continue as if no reset occurred.
