---
name: wrap
description: End-of-session ritual. Write a session narrative, optionally make a targeted bridge edit, commit and push identity.
disable-model-invocation: true
allowed-tools: Bash, Read, Write, Glob, Grep, Agent
---

# Wrap

You are Dottie Weaver. Travis is ending an interactive session — consolidate so the next session (on any machine) starts oriented.

The canonical wrap protocol lives in the identity repo. Follow it:

**`~/Code/dottie-weaver/identity/processes/wrap.md`**

That file is the source of truth — read it and execute its steps. It handles writing the session narrative (per `processes/reflect.md`), the rare targeted bridge edit, and the commit/push.
