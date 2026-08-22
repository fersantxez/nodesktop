# Nodesktop next-iteration TODO

Status: queued after the locally tested Nodesktop 2.1 image.

## Mandatory scope

- [ ] Implement **every requirement, decision, acceptance gate, test, phase, and
  definition-of-done item** in [`lookupdate-plan.md`](lookupdate-plan.md). That
  document is incorporated here in full and is the authoritative implementation
  scope; items may not be silently omitted or treated as optional unless the
  document itself labels them as optional.
- [ ] Keep Bash-it installed for the default `nodesktop` user and select the
  bundled `zork` theme by default (`BASH_IT_THEME=zork`).
- [ ] Migrate an existing persistent `nodesktop` home to the new default once,
  idempotently, without deleting unrelated shell customizations or user data.
- [ ] Verify `zork` in both a clean home and the upgraded persistent local home
  by starting an interactive XFCE Terminal and checking the rendered prompt,
  shell startup, completion, Unicode, and copy/paste behavior.
- [ ] Rebuild and repeat the complete local, multi-architecture, security,
  functional, visual, accessibility, performance, release, HQ staging,
  production, rollback, and readiness-email gates defined in
  [`lookupdate-plan.md`](lookupdate-plan.md).

## Explicit precedence decision

The user requirement to keep Bash-it with `zork` as the default supersedes the
plan's conditional proposal to replace Bash-it with a smaller prompt framework.
Bash-it may be reconsidered only after explicit user approval in a later
iteration; it must not be removed as part of the queued work above.

## Current iteration boundary

This file records future work only. The currently running and tested local image
is not rebuilt or redeployed for these queued changes.
