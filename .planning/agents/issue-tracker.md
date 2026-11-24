# Issue tracker

Canonical tracker: https://github.com/athan-dial/athan-dial.github.io/issues

Use native GitHub Issues and pull requests. Existing Wayfinder maps remain the decision-planning surface; do not replace them with a parallel backlog.

## Workflow

1. Resolve open requirements with the owner using Wayfinder or a focused design conversation.
2. Write the agreed specification as a GitHub issue: problem, solution, user stories, implementation decisions, testing decisions, acceptance and out of scope.
3. Decompose approved specs into independently verifiable vertical slices. State the parent and explicit Blocked by issue links. Do not admit blocked or underspecified tasks for execution.
4. Implement on isolated branches, verify against the originating specification, and review standards and specification fidelity independently.
5. Link the PR and exact tested SHA to the originating issues. Mark completion only when the issue's stated acceptance is observed. For a release, opening a PR is not completion.
6. Obtain separate human authorization for publishing, merging to production or lifting content gates.

Use gh in a checkout, or an authenticated GitHub connector. Read current issue states before creating duplicates. Use full issue URLs in handoffs. Review labels against triage-labels.md; preserve existing labels and Wayfinder conventions.

## Current work

- Parent reconciliation: https://github.com/athan-dial/athan-dial.github.io/issues/13
- Baseline integration: https://github.com/athan-dial/athan-dial.github.io/issues/14
- Architecture survey: https://github.com/athan-dial/athan-dial.github.io/issues/15
- Editorial strategy and revisions: https://github.com/athan-dial/athan-dial.github.io/issues/16
- Interactive architecture: https://github.com/athan-dial/athan-dial.github.io/issues/17
- Release evidence: https://github.com/athan-dial/athan-dial.github.io/issues/18

Existing release map #5 and issues #10/#11 remain the publication and post-deploy gates. Do not create another tracker or duplicate the full spec in files.

All issues and repository branches are public. Keep confidential evidence, private paths, credentials and internal source material outside them.
