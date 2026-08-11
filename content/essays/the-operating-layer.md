---
title: "When Measurement Cannot Choose for You"
type: essay
date: 2026-08-11
tier: cornerstone
summary: "Some model choices cannot be settled by a fair comparison. The honest response is to write down the strategic argument, the uncertainty, and what would change your mind."
status: draft
visibility: private
themes: [expert-workflows, product-judgment, reliable-ai-systems]
canonical_url: ""
draft: true
---

Model access is becoming ordinary. The hard part is deciding what to do when the model cannot settle the question in front of you.

I have [described this before](https://www.linkedin.com/feed/update/urn:li:activity:7447774093472546816/) in product terms: “The models are table stakes. What compounds is the operating layer: the workflows, the human-in-the-loop design, the institutional knowledge that can live in a system instead of someone's head.” I still believe that. But I think the claim has a harder edge than the usual discussion about workflows and adoption.

Sometimes a team cannot measure which approach is better. This is not always a failure of rigor. In some settings, the way the problem is constructed makes a fair comparison impossible.

That is the case I want to make: when measurement cannot choose for you, the honest move is not to manufacture a result or postpone the decision. It is to make the strategic argument in writing, before the outcome is known. Say what you are choosing, why you are choosing it, where the uncertainty sits, and what would change your mind.

That argument is not a substitute for evidence. It is what you owe the decision when the evidence you would need does not exist.

## A held-out test set buys you a particular kind of honesty

The clean version of model comparison is familiar. Keep some data out of development. Build competing approaches without looking at it. Test both against the same held-out set. The separation matters because it creates a check that neither approach was allowed to study in advance.

This can tell you something useful. Under the conditions of the test, one approach performed better on information neither had seen.

It still does not answer every product question. A benchmark is a measurement under specified conditions. A decision also has to account for the people using the result, the cost of being wrong, the available data, and how the system will be maintained. But at least the comparison has a fair empirical base.

Now consider a different setup. You have a small body of relevant information, and leaving some of it out would materially weaken the thing you are trying to build. You decide to use everything you know. That may be the right product choice. It also removes the untouched set that would have made a fair comparison possible.

You cannot then claim that one approach beat another on evidence both approaches were allowed to absorb. The comparison has been foreclosed by the setup. There is no measured winner.

I want to be precise here. I am not arguing that teams should stop holding out data. In most cases, they should protect a test set and treat leakage as a defect. I would revise my view if a credible evaluation design could preserve the information the deployed system needs while still producing an independent comparison between the choices. If that design exists, use it.

My claim applies to the narrower case where those two goals genuinely conflict: using all available information in the system and preserving enough untouched information to compare approaches fairly.

## The two evasions

When a team reaches that point, I see two tempting responses.

The first is to find a number anyway.

There is usually something available to count. You can report performance on the same material used to shape the approach. You can average several task-level scores. You can pick a convenient proxy. The output may look empirical because it has decimals and a chart. But the number does not restore the comparison the setup removed.

This is where the distinction between a benchmark and a decision matters. A benchmark can describe performance on a defined test. It cannot decide what the team should value, which failure is tolerable, or whether the test represents the conditions that matter. Those are choices made by people, even when they arrive dressed as a scoring function.

The second response is to wait.

If no metric can authorize the choice, the team treats the decision as premature. More analysis is requested. Another evaluation plan is drafted. The work remains open, sometimes because uncertainty has been mistaken for a temporary data problem.

More evidence is useful when it can change the decision. It is delay when the missing evidence cannot be produced under the chosen setup.

Both responses hide the same thing: somebody still has to decide what the system is for. The first buries that judgment inside a metric. The second avoids naming who owns it.

## Write the argument before you know the ending

There is a third option. Treat the choice as a strategic decision and write it down before the result arrives.

The document does not need to be grand. It needs to answer a few plain questions:

1. What are we choosing?
2. Why is a fair empirical comparison unavailable?
3. What evidence do we have, and what does it fail to establish?
4. Which expert judgments are carrying the choice?
5. What observation would cause us to revisit it?

This resembles pre-registration in science, but the purpose is different. You are not turning a strategy memo into a research protocol. You are creating a record that prevents the rationale from being rewritten after the outcome is known.

The timing matters. Written afterward, every choice can be made to look inevitable. Written beforehand, the assumptions are exposed while people can still disagree with them.

That changes the conversation. “Approach A scored higher” invites an argument about the score. “We are choosing approach A because false negatives are more costly in this workflow, the available evidence cannot compare the approaches fairly, and we will revisit the choice if review burden crosses this threshold” invites an argument about the actual decision.

The threshold in that sentence should be real if you have one. If you do not, do not invent it. Say that the revision condition has not been instrumented and specify what you would need to observe. An unmeasured condition is a gap to close, not a number to backfill.

Writing also makes disagreement useful. An expert can challenge the assumed cost of an error. An engineer can point out that the proposed observation will not be logged. A product leader can argue that the workflow rewards a different tradeoff. None of them has to pretend the disagreement is about model quality alone.

## Expert judgment is not the embarrassing remainder

The phrase “human in the loop” is often treated as a concession: the model is not good enough yet, so a person has to catch its mistakes. That framing misses the more important role.

Expert judgment is what lets a team act when the available measurements do not fully determine the choice. The expert knows which omissions matter, where a proxy breaks, and when two apparently similar errors have different consequences. That knowledge is not infallible. It should be challenged. But removing it from the system does not remove judgment. It moves judgment into defaults that are harder to see.

This is why the structure around the model matters. A reliable system needs a place to record why a choice was made. It needs to preserve the distinction between an observed result and an assumption. It needs a way for experts to disagree, escalate, and revise. It needs to show where the model ends and the product decision begins.

If a workflow flattens expert judgment into a single approval click, it has removed its own safety net. The person remains nominally involved, but the system has discarded the context that made their involvement valuable.

Institutional knowledge should live in a system instead of only in someone's head. That does not mean turning every judgment into a rule. It means making the reasoning available: the options considered, the evidence used, the uncertainty accepted, and the condition for another look.

This is also the limit of my argument. Written reasoning does not make a weak decision strong. Experts can share the same blind spot. A documented assumption can still be wrong. The value of writing is not that it guarantees the answer. It makes the basis of the answer inspectable before hindsight cleans it up.

## The decision is still ours

Cheap production can create more models, more scores, and more plausible outputs. It cannot relieve a team of choosing what deserves to be modeled, what evidence counts, or which errors matter in use.

When a fair comparison exists, run it. When one can be created without compromising the system you need to build, create it. When it cannot, say so plainly: there is no measured winner here.

Then make the argument where others can examine it. Name the judgment. Mark the missing evidence. Write down what would change your mind. That record gives the next person something better than a score to inherit: a decision they can understand well enough to challenge.
