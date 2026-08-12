# Claude configuration

`skills/` is **LEGACY**. Existing wrappers remain only until a separately
reviewed cleanup removes the package and installed entries. Do not add or
maintain shared skills there.

New shared local skills are exposed only through `~/.agents/skills`. The
knowledge-base-owned `present-for-decision` trial intentionally has no Claude
adapter; Claude Code access to it is out of scope.
