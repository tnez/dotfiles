# Local plans

This directory is checkout-local space for implementation plans, task handoffs,
and working notes. Only this README and `.gitignore` belong in Git. All other
files and subdirectories here are ignored, including nested plans and receipts.

## Publication boundary

- Keep execution journals, machine inventories, troubleshooting receipts,
  private paths, account/network details, and personal context local or in an
  appropriate private store. Do not force-add plans or attach them to public
  issues or pull requests.
- Promote useful outcomes into concise, reviewed public documentation: reusable
  architecture decisions in `docs/architecture/`, and maintenance/verification
  guidance beside the affected component. Remove private specifics and use
  placeholders where examples are needed. Public docs must stand on their own
  without links to an untracked local plan.
- Ready/Done decisions and verification evidence may be recorded in a local
  plan. Public handoffs should summarize the relevant outcome and limitations,
  not reproduce a session transcript.
- An exception requires an explicit publication decision, a privacy review,
  and a narrow update to this directory's allowlist. Do not bypass the policy
  with `git add -f`.

## Storage and safety

Ignored does not mean encrypted, access-controlled, or backed up. Do not put
passwords, tokens, private keys, or other secrets in plans. Local plans are not
transferred by clone, pull, or push; preserve important notes in private storage
before replacing a checkout. Commands such as `git clean -fdx` can delete them.

The ignore rules do not untrack files already committed or erase old versions
from Git history. Any history cleanup needs a separate remote-history check,
recovery backup, and explicit approval; never force-push as routine cleanup.

Inspect the boundary without changing files:

```sh
git ls-files -- docs/plans
git check-ignore -v docs/plans/example-local-plan.md
```

The tracked listing should contain only `docs/plans/README.md` and
`docs/plans/.gitignore`. Plans can remain on disk without appearing in ordinary
Git status. Do not delete them merely to obtain a clean working tree.
