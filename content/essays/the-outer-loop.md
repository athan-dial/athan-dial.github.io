---
title: "The Outer Loop"
type: essay
date: 2026-08-12
tier: cornerstone
# Homepage selects on the boolean `cornerstone`; /thinking/ selects on `tier`.
# Both are set deliberately — see the note in the commit message.
cornerstone: true
summary: "AI makes the plan-build-verify loop faster, which also makes it easier to perfect the wrong product. The outer loop keeps the user, the problem, and the product shape open to question — and it matters more now that the expert can arrive with a prototype."
status: published
visibility: public
themes: [expert-workflows, product-judgment]
# Originally published as a LinkedIn Pulse article. This is the ARTICLE url, not the
# feed post that promotes it. The site permalink stays the HTML canonical (see
# partials/schema.html); the template treats a linkedin.com value here as distribution
# only and renders a "View on LinkedIn" button.
# Companion feed post, for provenance — no template consumes it today:
#   https://www.linkedin.com/feed/update/urn:li:activity:7493263472353497088/
canonical_url: "https://www.linkedin.com/pulse/outer-loop-product-judgment-athan-dial-3n79c/"
draft: false
---

A few weeks ago, I was talking with a colleague about adding a chat agent to an internal tool.

I asked,
> Why is this an app?

The feeling was hard to shake: _what if the useful part is the capability underneath the interface?_ If we expose it where technical users already work, perhaps through an MCP server (a governed way to call a tool or retrieve data), they could compose the experience they need.

Their pushback was clean and simple: user friendliness. A dedicated application would make the capability available to people who were not going to assemble a workflow around it themselves. I initially heard that as an argument about the best implementation, but it wasn't that. We were describing different users.

In reality, we could have prototyped either version, tested it, found the problems, and improved it. That would have helped us build the thing correctly while still missing the more important question: _which thing should exist, for whom, and which part of it should become shared infrastructure?_

For lack of a better term, that is the outer loop: stepping outside the solution long enough to keep the user, the problem, and even the product shape open to question.

## The inner loop can perfect the wrong product.

Most tech product work now has some version of an inner loop:

**Plan → build → verify → revise.**

AI is making that loop faster. Teams can produce more interfaces, analyses, agents, and workflows; they can test more variations and repair failures with less effort. That is useful. A real artifact exposes details that discussion alone will miss.

The inner loop does, however, inherit a set of assumptions. It assumes that the team has identified the relevant user, understood the practice being changed, and chosen a reasonable product boundary. If those assumptions are wrong, the loop, especially hopped up on AI, can make the wrong solution increasingly convincing.

This matters in scientific work because the workflow is rarely just a sequence of steps waiting to be automated. Some parts repeat. Others depend on context, tacit knowledge, or judgment that changes with the situation. The product boundary, the "shape" of the thing, is often part of what the team is still learning.

## The outer loop keeps the inner loop honest.

The outer loop orbits around the plan-build-verify cycle and keeps its assumptions available for revision. It is how you pursue the best thing you can make without treating your definition of "best" as settled.

It asks:
- *Who is actually using this?*
- *What are they trying to accomplish?*
- *Which part of the work repeats?*
- *Where does contextual judgment remain?*
- *What can the expert already compose well?*
- *What must be dependable before that local work can be trusted?*

This is not a stage gate or a bottleneck dressed in ceremony. It is a practiced way of thinking: the inner loop produces evidence, and the outer loop uses it to decide what should be explored next. That movement is consistent with research describing problem and solution spaces as co-evolving: an emerging solution changes how the problem is understood, which changes the next solution ([Dorst and Cross, 2001](https://sites.cc.gatech.edu/classes/AY2013/cs7601_spring/papers/Dorst_Cross2001.pdf)). Building is part of the thinking. It just should not end the thinking.

In my app conversation, "user-friendly" was not the answer. It was more questions: _friendly to whom, doing what, with how much expertise, and at what cost if we're wrong?_ Our implementation debate had hidden something more basic: we had not zoomed out enough to define what "best" meant.

A guided application could be right for an occasional user, while a programmatic tool could be right for someone who lives in a terminal all day. And as the available ways to build change, those answers can move underneath you. The app you are carefully designing may be less useful than a capability the user can call from the agent they already work in.

That makes the outer loop more important, not less. Because the user is no longer only waiting for you to build the solution.

## Move over, mockup: the user brought a prototype.

Users have always adapted tools to fit their work. [Eric von Hippel](https://web.mit.edu/evhippel/www/books/DI/DemocInn.pdf) documented this pattern long before generative AI: users often create solutions for needs they understand earlier or more precisely than producers do. That explains the spreadsheet. You know the one. It is held together by formulas, voodoo, and a process that has been stubbornly surviving for an era. It is also not going anywhere, no matter how fast your BI pipeline runs.

What is becoming clearer is that users never lacked imagination so much as implementation leverage. They could see the problem clearly and often hack around it, but turning that workaround into something more complete usually required translation through a product or technical team.

AI compresses that translation step. A domain expert can now move from an idea to a working script, analysis, or interface before needing anyone else.

The work does not disappear. It shifts outward. Less effort goes into translating an idea into implementation; more of it can go into deciding what should exist, for whom, under what conditions, and how we would know if it is actually better.

> Expertise steers. Systems execute.

Coding gives us an early version of that shift. In an analysis of roughly 400,000 Claude Code sessions, Anthropic found that people made about 70% of planning decisions, while the agent made about 80% of execution decisions. Task-specific expertise was also associated with higher success and longer chains of useful work from each instruction ([“Agentic coding and persistent returns to expertise”](https://www.anthropic.com/research/claude-code-expertise)). The interesting part is not that AI can write code. It is that expertise can stay focused on planning while more of the implementation moves into the system.

There is an important boundary here. Coding is unusually verifiable: tests can pass, code can be committed, and failures often leave a trace. The study also could not observe whether the resulting artifact produced a useful real-world outcome. I would not generalize from it to all expert work.

But as a signal, it matters. Technical implementation no longer cleanly separates the person who understands the problem from the person who can make something tangible. Building is moving closer to the problem. Increasingly, the expert can arrive with a prototype.

That makes the inner loop more accessible. It also makes the outer loop easier to skip.

## A prototype is evidence, not a standard.

A prototype built by an expert is unusually rich evidence. It can reveal how they describe the work, which information they prioritize, what they repeat, where they need flexibility, and what they consider a plausible result. But it also does something more consequential: it proposes the first product shape.

For better or worse, that initial shape can be sticky. Research on design fixation found that an example solution can anchor what people design next, even when its flaws are made visible ([Jansson and Smith, 1991](https://www.sciencedirect.com/science/article/pii/0142694X9190003F)). AI raises the stakes because it can produce persuasive examples quickly. A workable interface can start answering "what should we build?" before anyone has asked whether that interface is essential to the need or simply the first convenient expression of it.

The tension appears when that prototype leaves the expert's hands. Locally, it may reasonably feel like progress: the workflow works, the result looks plausible, the pain is lower. To the team being asked to support it, the same artifact may reveal duplicated logic, privacy concerns, uncertain provenance, and a maintenance obligation that were invisible while it was local.

That does not make the prototype disposable. Quite the opposite. It is evidence about the need and about the expert's model of the work. What it is not is proof that its particular shape should survive.

That is where the outer loop comes back in: what remains valuable when you remove the prototype's interface, implementation, and local assumptions?

## The outer loop looks for shared ground.

The strongest counterargument to local composition is that organizations cannot allow every expert tool to invent its own data definitions, permissions, evidence standards, and verification logic. Handing everyone an agent and waiting for coherence to emerge seems optimistic, even by software standards.

And not everyone wants to compose their own solution. Executives, administrators, occasional users, and plenty of domain experts still need software that simply works. They are not trying to become AI power users. So more local building does not eliminate the need for product work. It changes where some of that work belongs.

More local building may actually increase the value of shared foundations: data, provenance, evaluation, interoperability, permissions, or dependable capabilities that many experiences can use. Some users will compose on top of those foundations. Others will encounter them through software someone else has designed for them.

I ran into a small version of this in a conversation about whether to generalize a narrow data structure. The architectural instinct was familiar: _make it reusable._ But the immediate job was narrow, and that is where the outer loop should start setting off your spidey-sense.

_How often does this pattern actually recur?_\
_How painful is it when it does?_\
_What does generalizing it cost?_

If it was a common unit of work, abstraction could create shared leverage. If it was a one-off we were already handling with good hygiene, abstraction would mostly create overhead and maintenance. So the sensible move was to keep the current version narrow, preserve a seam for change, and watch for recurrence. Sometimes the right abstraction is deciding not to create one yet.

The technical discussion was about architecture. Underneath it, we were trying to determine whether we had found common structure in expert work: something recurring, expensive, or trust-sensitive enough that people should not each have to solve it alone. That is the shared ground worth building for.

## Build what experts should not have to rebuild.

The product may be an application. It may be a capability beneath several applications that no one ever sees, or a trusted data and verification layer beneath several local tools. Sometimes the bespoke prototype is exactly enough, and the organization should leave it alone.

The inner loop helps make any of those forms work. The outer loop keeps the form itself contestable.

I still ask, "Why is this an app?"

But the outer loop gives me a more precise version of the question:
> What should experts be free to build, and what should they never have to rebuild?
