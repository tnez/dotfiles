# Docent Knowledge Base

This directory is managed by docent, a documentation intelligence system.

## Structure

- `templates/` - Custom templates (override bundled templates)
- `runbooks/` - Custom runbooks (override bundled runbooks)
- `journals/` - Work journals (gitignored)
- `sessions/` - Agent session logs (gitignored)
- `notes/` - General notes and knowledge capture
- `projects/` - Project tracking documents
- `decisions/` - Architecture Decision Records (ADRs)
- `proposals/` - RFCs and PRDs

## Usage

- `/docent:ask [query]` - Search all documentation
- `/docent:tell [statement]` - Write/update documentation
- `/docent:act [directive]` - Execute runbooks
- `/docent:start` - List available templates and runbooks

## Configuration

Edit `config.yaml` to customize search paths and project settings.
