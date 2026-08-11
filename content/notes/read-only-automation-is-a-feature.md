---
title: "Read-only automation is a feature"
type: note
date: 2026-04-06
summary: "I keep automations in draft: Claude proposes, I send—parallel drafts for speed, human gate for tail risk after a near-miss taught me the cost of auto-send."
status: published
visibility: public
themes: [reliable-ai-systems, expert-workflows]
source_url: https://athan-dial.github.io/agency/dispatches/read-only-automation-is-a-feature/
draft: false
---
Two months ago I wired Cowork to auto-send follow-ups on support tickets. I meant to flip it back after the test run; I didn’t. Next morning a draft almost went to the wrong customer because a shared thread looked like the outbound compose I thought I was in. I caught it on the way out the door.

Default now: read-only automation. Claude pulls context, writes the draft, stops. I send. I still get speed from drafts queued in parallel, and I see the outbound before it meets the world when Jira, mail, or the calendar are lying about state.

**Draft mode surfaces intent.** When I keep the loop manual, I review the language, the audience, and the timing. If Claude misreads the thread and thinks a sarcastic aside is an action item, I spot it before embarrassment hits production. Read-only output lets me interrogate intent without undoing damage.

**Approval catches state drift.** Systems lie more than people expect. A Jira ticket marked “Done” might hide a failing test. A calendar entry could be in the wrong timezone. If an automation acts on those signals without human review, it amplifies the error. When Claude hands me a draft comment or command, I check the live state and confirm we’re still on solid ground.

**Draft mode preserves accountability.** Sending an email, merging a branch, or pinging a partner is a social act. When the automation is the last touch, nobody knows who owns the outcome. When I review the draft and choose to send, I accept responsibility. I own the send; Claude proposed.

**The time cost is small.** Reviewing a draft takes seconds. Recovering from an automated misfire consumes hours: apologizing, reopening work, untangling trust. Automation should buy leverage, not lottery odds.

I still automate aggressively. Cowork reads every document I read and summarizes the action items. Claude Code prepares patches, migrations, and analysis artifacts faster than I can type. The distinction is execution rights. Proposals flow nonstop; actual sends stay human-triggered. Speed comes from parallel drafts that wait in my outbox until I confirm they match intent.

The near miss with that auto-sent email reminded me that flipping full autonomy without a gate cost more than the minutes it saved. Drafts keep the model working at full speed while I weigh consequences. Tail risk stays inside my review window, where I can still intervene.
