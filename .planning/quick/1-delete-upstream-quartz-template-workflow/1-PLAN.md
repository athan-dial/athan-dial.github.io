---
phase: quick
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - ~/Documents/GitHub/model-citizen/.github/workflows/ci.yaml
  - ~/Documents/GitHub/model-citizen/.github/workflows/docker-build-push.yaml
  - ~/Documents/GitHub/model-citizen/.github/workflows/build-preview.yaml
  - ~/Documents/GitHub/model-citizen/.github/workflows/deploy-preview.yaml
autonomous: true

must_haves:
  truths:
    - "Only deploy.yml remains in .github/workflows/"
    - "4 upstream Quartz template workflows are deleted"
    - "Changes committed and pushed to model-citizen repo"
  artifacts: []
  key_links: []
---

<objective>
Delete 4 upstream Quartz template workflow files from the model-citizen repo that always skip due to `github.repository == 'jackyzha0/quartz'` guards.

Purpose: Clean up dead workflow files inherited from Quartz template.
Output: model-citizen repo with only deploy.yml remaining in .github/workflows/
</objective>

<execution_context>
@/Users/adial/.claude/get-shit-done/workflows/execute-plan.md
@/Users/adial/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
Target repo: ~/Documents/GitHub/model-citizen/
Files to delete: ci.yaml, docker-build-push.yaml, build-preview.yaml, deploy-preview.yaml
File to keep: deploy.yml
</context>

<tasks>

<task type="auto">
  <name>Task 1: Delete upstream Quartz workflows and push</name>
  <files>
    ~/Documents/GitHub/model-citizen/.github/workflows/ci.yaml
    ~/Documents/GitHub/model-citizen/.github/workflows/docker-build-push.yaml
    ~/Documents/GitHub/model-citizen/.github/workflows/build-preview.yaml
    ~/Documents/GitHub/model-citizen/.github/workflows/deploy-preview.yaml
  </files>
  <action>
    In the model-citizen repo at ~/Documents/GitHub/model-citizen/:

    1. Verify the 4 files exist and contain the `jackyzha0/quartz` guard
    2. Verify deploy.yml exists and does NOT have the guard
    3. Delete the 4 files:
       - .github/workflows/ci.yaml
       - .github/workflows/docker-build-push.yaml
       - .github/workflows/build-preview.yaml
       - .github/workflows/deploy-preview.yaml
    4. Commit with message: "chore: remove upstream Quartz template workflows"
    5. Push to origin
  </action>
  <verify>
    `ls ~/Documents/GitHub/model-citizen/.github/workflows/` shows only deploy.yml
  </verify>
  <done>Only deploy.yml remains in .github/workflows/. Changes pushed to remote.</done>
</task>

</tasks>

<verification>
- `ls ~/Documents/GitHub/model-citizen/.github/workflows/` shows exactly 1 file: deploy.yml
- `git -C ~/Documents/GitHub/model-citizen log -1 --oneline` shows the cleanup commit
</verification>

<success_criteria>
4 upstream Quartz template workflows deleted, only deploy.yml remains, changes pushed.
</success_criteria>

<output>
After completion, create `.planning/quick/1-delete-upstream-quartz-template-workflow/1-SUMMARY.md`
</output>
