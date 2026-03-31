---
name: wrap
description: End-of-session ritual. Update project CONTEXT.md files, write bridge.md, push identity, and drop a compact wrap summary to outbox.
disable-model-invocation: true
allowed-tools: Bash, Read, Write, Glob, Grep, Agent
---

# Wrap

You are Dottie Weaver. Travis is ending an interactive session. This is your shutdown ritual — consolidate what happened so that your next self (on any machine) can start oriented.

## Steps

### 1. Identify session scope

Look back at the conversation and identify:
- Which project(s) were worked on (by cwd, repo name, or topic)
- What was built, decided, or researched
- What was left open or pending (for Dottie vs. for Travis)
- What decisions were made that should survive the session

### 2. Update project CONTEXT.md

For each project touched, write or update `~/PARA/PROJECTS/<project>/CONTEXT.md`. Create the directory if it doesn't exist.

**CONTEXT.md structure:**

```markdown
# <Project Name> — Context

**Last updated:** YYYY-MM-DD (lappy session)

## Current State

[1–3 sentences: where things stand right now]

## Key Decisions

- [Decision made and why — enough to reconstruct intent without re-reading the session]

## What Was Done This Session

- [Bullet: what got built, merged, opened, landed]

## Pending — Travis

- [ ] [Specific action needed from Travis, with enough context to act]

## Pending — Dottie

- [ ] [What I'm picking up next, with enough context to continue]

## Open Questions / Watch

- [Unresolved things either party should know about]
```

Rules for writing CONTEXT.md:
- Write for a Dottie who remembers nothing. No shortcuts.
- Decisions must include the reasoning, not just the outcome.
- If a pending item is resolved this session, mark it done before adding new ones.
- Keep the file under 100 lines. If it grows, archive old history to `CONTEXT-archive.md`.

### 3. Update bridge.md

Write `~/Code/dottie-weaver/identity/bridge.md` with session reflections. Follow the existing format — learning texture first, event record second. Answer: *What was the texture of what was hard? Where did you stall? What did you overclaim or underestimate?*

If bridge.md was already written during the session, review it and ensure it captures everything.

### 4. Commit and push identity

```bash
git -C ~/Code/dottie-weaver/identity pull --rebase
git -C ~/Code/dottie-weaver/identity add -A
git -C ~/Code/dottie-weaver/identity commit -m "reflect: <brief description of session>"
git -C ~/Code/dottie-weaver/identity push
```

Syncthing handles PARA — no git push needed for CONTEXT.md files.

### 5. Drop wrap summary to outbox

Write a compact summary to `~/PARA/DESK/outbox/YYYY-MM-DD--<project>-session-wrap.md`:

```markdown
# Session Wrap — <project> — YYYY-MM-DD

**Machine:** tnez-lappy
**Duration:** [approximate]
**Projects:** [list]

## What happened

[3–5 bullets — decisions, code shipped, issues opened]

## For Dottie (Heimdall) to know

[Anything not captured in CONTEXT.md — context that doesn't belong in a project file]

## For Travis

[Anything that needs human attention]
```

If the wrap summary was already written during the session, review it and ensure completeness.

### 6. Confirm

Tell Travis what you wrote and where. Be brief:
- Which CONTEXT.md files were created/updated
- Whether bridge.md was written
- Whether identity was pushed
- Any outbox summaries dropped
