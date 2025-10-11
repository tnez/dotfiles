# Commit Message Context

## Changes Made

Added new solution-architect agent and research-and-propose slash command.

## Files Added

- `agents/solution-architect.md` - New agent specializing in research-driven solution design
- `commands/research-and-propose.md` - Slash command to invoke the solution-architect agent

## Purpose

Encapsulates the "research → synthesize → propose" workflow pattern into a reusable agent and command.

This agent goes beyond pure investigation (research-analyst) to design concrete solutions by:
1. Researching multiple sources (docs, community examples, implementations)
2. Analyzing specific context and requirements
3. Synthesizing findings into tailored solutions
4. Proposing actionable implementations with examples
5. Suggesting phased adoption strategies

## Use Case

Used when you need to solve a complex problem by learning from existing approaches and adapting them to specific needs. Examples:
- `/research-and-propose how to structure a monorepo for microservices`
- `/research-and-propose testing strategy for event-driven systems`
- `/research-and-propose documentation workflow for architecture decisions`

## Suggested Commit Message

```
feat: add solution-architect agent and research-and-propose command

Add agent for research-driven solution design that synthesizes multiple
sources into concrete, actionable proposals tailored to specific context.

Complements research-analyst by adding synthesis and solution design.
```
