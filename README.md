# act

The workflow **model** and **expression parser** used by Hanzo Git Actions.

A fork of the `act/` subtree of `gitea.com/gitea/runner`, reduced to the four
packages a forge actually needs to parse and evaluate workflows:

| package      | what it does                                       |
|--------------|----------------------------------------------------|
| `model`      | workflow / job / step parsing and planning         |
| `exprparser` | GitHub Actions expression evaluation               |
| `common`     | shared helpers (cartesian product, dry-run)        |
| `common/git` | git ref and revision helpers                       |

The container-execution half of upstream is deliberately absent: running a job
is the runner's business, and a forge that only reads workflows should not carry
a container runtime to do it.

Upstream is MIT and its copyright notices are retained.
