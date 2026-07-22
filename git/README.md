# Personal git workflow

Repositories that use worktrees have a persistent primary checkout with sibling
worktrees organized by branch prefix:

```text
project/
|-- main/.git/
|-- feat/...
|-- review/...
|-- chore/...
`-- docs/...
```

Initialize `wtp` from the primary checkout:

```bash
cd project/main
wtp-init.sh
git add .wtp.yml
git commit -m 'chore: configure worktrees'
```

Typical workflow:

1. Update remote-tracking branches: `g f`
2. Create a branch from main: `wtp add -b feat/example main`
3. Return to main: `wtp cd @`
4. List worktrees: `wtp list`
5. Remove a merged worktree and branch: `wtp remove --with-branch feat/example`

Existing remote branches can be checked out with `wtp add feat/example`. If the
same branch exists on multiple remotes, create the desired local tracking branch
first so `wtp` can resolve it unambiguously.
