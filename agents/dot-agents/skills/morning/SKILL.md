---
name: morning
description: Synthesize a morning briefing from GH notifications, calendar, reminders, and inbox.
---

# Morning Briefing

Compile a single scannable morning briefing for Travis. Gather all sources in
parallel, then synthesize.

## Gather Data

Run these source checks in parallel where the harness allows it.

GitHub:

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

Calendar:

```bash
icalBuddy -n -nc -nrd -ea eventsToday 2>/dev/null
```

```bash
icalBuddy -n -nc -nrd -ea eventsToday+1 2>/dev/null
```

Reminders:

```bash
osascript -e '
set output to ""
tell application "Reminders"
  repeat with reminderList in every list
    set listName to name of reminderList
    set dueItems to (every reminder of reminderList whose completed is false and due date is not missing value and due date is less than or equal to (current date))
    repeat with r in dueItems
      set output to output & "[" & listName & "] " & name of r & " (due " & short date string of due date of r & ")" & linefeed
    end repeat
  end repeat
end tell
return output
' 2>/dev/null
```

Inbox:

```bash
ls -1 ~/PARA/DESK/inbox/ 2>/dev/null
```

## Synthesize

Present a single briefing with these sections. Skip any empty section.

- **Needs Attention**: PRs needing review, overdue reminders, anything
  time-sensitive. Bold items that need action today.
- **Today's Schedule**: calendar events, formatted as a timeline.
- **Open Work**: open PRs and assigned issues. Keep this brief.
- **Inbox**: files sitting in `~/PARA/DESK/inbox`, if any.
- **Tomorrow Preview**: tomorrow's calendar at a glance.

Keep it scannable. Use bullet points. Be concise.
