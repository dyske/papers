# Distillation, the Loop, and the Dimensions of Learning

A set of notes connecting how AI models are trained to how people learn, built around three ideas: what distillation loses, what the learning "loop" actually consists of, and why dimensionality is what produces good instinct.

## Distillation: what it transfers and what it loses

Distillation means training one model on the outputs of another: a "student" learns to reproduce a "teacher." The intuition that it loses "the details that led to the correct conclusions" is true for the crude version and false for the careful one. What matters is whether the details were ever in the training signal.

In the crude case you collect only final answers, question in and answer out, with nothing in between. The student learns to map inputs straight to conclusions and finds a shallow shortcut that works inside its training distribution and breaks just outside it. It learned the answer, not the route.

A sharp result here is the Berkeley work (around 2023) on imitating proprietary models. Small models fine-tuned to copy ChatGPT's outputs learned to *sound* right without being right: they picked up the style of competence, the confident tone, the clean formatting, and fooled human raters, while their actual capability on knowledge-heavy tasks stayed flat and they hallucinated fluently. Imitation closes the stylistic gap, not the capability gap. You cannot pour in knowledge the student's base model never acquired just by showing it polished answers.

But the claim breaks down when you distill the reasoning itself, which is what made DeepSeek's R1 distillation notable. They generated the full chain of thought and trained smaller models on those traces, so the steps that led to the conclusion were present and transferred. "Distillation lacks the details" is only true when the details were never externalized.

One more wrinkle cuts the other way. Classic distillation trains the student on the teacher's full output distribution, not just its chosen answer. That distribution carries "dark knowledge": the relative probabilities reveal what the teacher considered and rejected and by how much, which is more than a bare right answer. But you only get it with access to the teacher's internals. Black-box distillation through an API gives only sampled text, so that richer signal is exactly what gets discarded.

The principle underneath all of it: distillation transfers behavior, not the thing that generated the behavior. A distilled model is anchored to the teacher's outputs rather than to reality, so it inherits the teacher's blind spots, cannot verify anything independently, and in pure form cannot exceed its teacher. It learns to act like the model that knew, which is not the same as knowing.

## Helicopter parenting as distillation

Feeding a child correct answers without letting them generate and test their own is the same maneuver. The two failure modes map almost one to one.

Brittleness is the cleanest fit. A kid who sailed through a structured, supervised childhood comes apart in the first genuinely unstructured situation, not from lack of intelligence but because they were trained on outputs rather than on the search.

The imitation finding maps even more sharply, and it is the less comfortable one. The kid becomes excellent at presenting as capable, the polished answer, the right credential, a resume that reads like a frontier model, while the generative engine underneath was never built. They pass the human-rater test and fail the open world.

This also disposes of the obvious objection, that plenty of over-managed kids outperform their parents. Sure, on the dimensions the parent optimized; they beat the benchmark the teacher set. What they cannot do is the thing off the benchmark, the unspecified situation with no answer key. The imitation gap closes and the capability gap does not.

The healthy alternative has a name in machine learning: reinforcement learning. DeepSeek's genuine breakthrough, the part that was not copying, came from RL. R1-Zero developed its reasoning largely by generating its own attempts and being rewarded only for verifiably correct outcomes, with nobody supplying the steps. The distilled student inherits capability and is capped below its teacher; the RL learner grows capability and can find moves nobody taught it. One is copied, the other is grown.

## What the loop actually consists of

If the lesson is "let them run the loop, not just hand them answers," the natural question is what the loop is made of, if not the wrong result.

The wrong result by itself is almost nothing, a single bit that says *that failed*. If that bit were the valuable thing, being told it would work as well as doing, and it does not. The content is everything the result lets you infer, and that inference only works because the result is bound to an action you generated yourself.

That binding is the irreducible ingredient. When you act and feel the consequence, your motor command and the sensory result arrive together, so you can assign credit: this thing I did produced that result. A told rule is detached from your own action, so there is nothing for the lesson to attach to. That is why hearing the conclusion, or watching someone else fail, is so much weaker than failing yourself.

Given that hook, three distinct things get built, none of which is "the wrong answer":

1. **A sensory model.** You do not just learn "sharp is better," you learn what approaching failure feels like, the specific resistance and skid that means it is about to go wrong. The rule is a compressed label; the loop installs the high-dimensional feeling the label points at.

2. **A recovery policy.** This is the big one, and the thing a clean demonstration can never contain. A successful demonstration only ever travels the path that works; it never enters the bad states, because the expert does not. So the learner gets the one good line through the problem, and the instant they deviate, which a beginner will, they are in a state the demonstration never visited, with no response available. Having flailed around yourself, you populated the whole neighborhood of bad states with responses. You know what to do once it is already going wrong, which is exactly what the demonstration omits. The wrong results were how you explored that neighborhood.

3. **A causal decomposition.** By varying things, often involuntarily, you learn which variable does what, so you can adapt to a new tool or a new case. Handed the bundled procedure, the learner has the output but not the separable variables and cannot recombine it for a situation that was not covered.

The machine-learning version: learning from demonstrations alone is behavioral cloning, and its signature failure is precisely this. The learner drifts off the expert's trajectory into states the demonstrations never showed, has no idea how to recover, and errors compound. RL fixes it by having the learner generate its own trajectories, including the bad ones, and bind each to its outcome.

The compact way to hold it: **the answer is the path; the loop is the terrain on either side of the path; and you can only map the terrain by stepping off the path.**

## Dimensions and why they produce instinct

A model's competence lives in its weights and, for any input, in a high-dimensional trajectory of activations through its layers: thousands of dimensions per layer, billions of parameters, a geometry we cannot hold in our heads or even read well. That representation is the substrate. Its output is a projection of that substrate onto a single narrow channel, at most a probability distribution over the vocabulary, and in practice, over an API, one sampled thread of text. The pipeline runs from an enormously high-dimensional representation down to an output distribution down to one realized trajectory, and every step throws away dimensions.

Distillation hands the student the output and asks it to reconstruct the substrate. That is inverting a projection, which is underdetermined: many internal geometries produce the same outputs, so the student settles on whatever cheapest one fits the threads it saw, not the teacher's robust one. The dimensions that got projected away are the ones it cannot recover, because nothing in the data constrains them, and those lost dimensions are disproportionately the ones carrying generalization.

Why high dimensionality produces instinct: generalizing to a situation you have never seen works by the new situation being near familiar ones in some representational space, so the learned response carries over by proximity. The more dimensions your representation genuinely captures, the more ways a novel case can be near something you know, and the more cases you handle by interpolation instead of being stranded. Instinct is fast interpolation in a richly structured space. A representation collapsed down to "the answer" has almost no neighborhood structure: a new case is either the one you memorized or a cliff edge. Embodiment gives you the rich metric precisely because the hand, the eye, and the sense of balance each contribute a dimension along which two situations can count as similar.

One honest complication, and the reason distillation works at all: language is an unusually good projection. It did not evolve as a random axis; it carries a great deal of the relevant structure, which is why a student recovers more from text than the raw dimensionality would predict. Chain-of-thought is essentially a trick to widen the channel, dragging more of the internal trajectory into the observable output, which is why distilling reasoning traces transfers more than distilling bare answers. It does not escape the projection problem, it just makes the projection less lossy. The dimensions orthogonal to anything the model ever puts into words are still gone.

## Devices, screens, and the Jobs point

Answer-delivery devices do the helicopter move without a parent. The cleanest case is GPS: navigating by turn-by-turn directions forms weaker spatial memories and engages the hippocampus less, while drivers who had to build the map themselves grew theirs. The device hands you the answer and the loop that would have built the internal map never runs. The general name is cognitive offloading: we remember where to find a thing instead of the thing, and the delegated skill quietly fails to develop.

But "devices give correct answers" picks out the wrong variable, and the dimensionality point shows why. A video game gives almost nothing but the loop: act, fail, retry, build instinct. So devices do not uniformly short-circuit the loop; what they do is run it in a dimensionally thin world. A screen collapses interaction to a flat, narrow channel: tap, swipe, instant clean response, no force feedback, no weight, no consequence that does not reset. The real problem is the thinness, plus the loss of genuine consequence, since you can always retry and nothing actually costs you anything.

So the right contrast is not nature versus technology. It is rich, consequential, embodied loops against thin, frictionless, resettable ones. Nature is a superb instance of the first kind, but not the only one; a workshop, a kitchen, an instrument, a sport, an animal to keep alive all qualify. A child raised in the woods but handed every answer still misses the loop; a child with the run of a garage gets it. Nature is a proxy for the variable, not the variable itself.

On Jobs: the design philosophy that made his products great was the removal of friction. It just works, no manual, nothing to understand. That frictionlessness is loop removal, because a tool you never struggle with never makes you build anything. The property that is a virtue for the user is a vice for the learner, engineered by the same hand. And he reportedly kept his kids off the iPad in particular, the most consumption-oriented thing he made, the purest case of the thin frictionless channel. Whether he had the theory or just a good gut, the instinct landed on the right target.

## The through-line

In every version of the story the same split appears. What transfers is the projection: the answer, the path, the transcript, the shadow. What does not transfer is the high-dimensional generating structure: the loop, the embodied representation, the activation geometry, the terrain. Telling, behavioral cloning, distillation, and the hovering parent are all one maneuver, transmitting the shadow and hoping the substrate reconstitutes itself. Usually it does not, or it grows a cheaper stand-in that matches the shadow and lacks the directions you could not see. The only known way to get the substrate is to generate your own attempts and meet your own consequences, in a world with enough dimensions and enough stakes for the feedback to mean something.
