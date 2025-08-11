# Yazi Configuration

## File Movement

### Standard Move (Built-in)
1. Select files with `Space`
2. Cut with `x` 
3. Navigate to target directory
4. Paste with `p`

### Enhanced Move Commands

- **`mf`** - Move with fuzzy finder
  - Uses `fzf` to search and select target directory
  - Searches from home directory
  - Creates directory if needed

- **`mn`** - Move to new directory
  - Prompts for directory name
  - Creates the directory
  - Moves selected files

## Delete Operations

- **`dd`** - Safe delete (moves to trash)
- **`DD`** - Force delete (permanent, no trash)

## Apple Integration

- **`Rr`** - Create Apple Reminder (capital R then r)
  - Attaches selected file reference
  - Prompts for title, notes, and due date
  - Opens Reminders app

## Dependencies

- `fd` - For directory searching
- `fzf` - For fuzzy finding
- `realpath` - For absolute paths (part of coreutils)

Install with:
```bash
brew install fd fzf coreutils
```