# Personal git workflow

1. Get up-to-date with remotes: `g f`
1. Browse open issues (applies for some projects): `ghi`
1. Show details of issue (sometimes): `ghi show 42`
1. Spin-up a new branch: `g co -b new-feature`
1. _Do work_
1. Review, add, and commit changes: `g d <master> , g aa, g c`
1. (Optionally) clean up local commits: `g ri <master | HEAD~n>`
1. Push: `g p` (TODO: script to add tracking if not already set)
1. (Optionally) check **CI** status `ghs`
1. Open pull-request: `ghp`
