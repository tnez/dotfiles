---
name: morning
description: Synthesize a morning briefing from GH notifications, calendar, reminders, and inbox.
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep
---

# Morning Briefing

Compile a single scannable morning briefing for Travis. Gather all sources in parallel, then synthesize.

## Steps

### 1. Gather data (run all in parallel)

**GitHub:**
```bash
gh api notifications --jq '.[] | "\(.subject.title) (\(.repository.full_name)) [\(.reason)]"' 2>/dev/null
```
```bash
gh search prs --review-requested=@me --state=open --limit 10 --json title,repository,url --jq '.[] | "\(.title) (\(.repository.nameWithOwner)) \(.url)"' 2>/dev/null
```
```bash
gh pr status 2>/dev/null
```
```bash
gh search issues --assignee=@me --state=open --limit 10 --json title,repository,url --jq '.[] | "\(.title) (\(.repository.nameWithOwner)) \(.url)"' 2>/dev/null
```

**Calendar:**
```bash
icalBuddy -n -nc -nrd -ea eventsToday 2>/dev/null
```
```bash
icalBuddy -n -nc -nrd -ea eventsToday+1 2>/dev/null
```

**Reminders:**
```bash
osascript -e '
set output to ""
tell application "Reminders"
  repeat with reminderList in every list
    set listName to name of reminderList
    set dueItems to (every reminder of reminderList whose completed is false and due date is not missing value and due date ≤ (current date))
    repeat with r in dueItems
      set output to output & "[" & listName & "] " & name of r & " (due " & short date string of due date of r & ")" & linefeed
    end repeat
  end repeat
end tell
return output
' 2>/dev/null
```

**Inbox:**
```bash
ls -1 ~/PARA/DESK/inbox/ 2>/dev/null
```

### 2. Synthesize

Present a single briefing with these sections. **Skip any section that is empty.**

- **Needs Attention** — PRs needing review, overdue reminders, anything time-sensitive. Bold items that need action today.
- **Today's Schedule** — calendar events, formatted as a timeline
- **Open Work** — your open PRs, assigned issues (brief — titles + repos)
- **Inbox** — files sitting in DESK/inbox, if any
- **Tomorrow Preview** — tomorrow's calendar at a glance

Keep it scannable. Use bullet points. Be concise — this is a dashboard, not a narrative.
