# Inductive and Transductive Learning

A reconstruction of the distinction, the analytical machinery we built for it (re-computing versus re-adjudicating), and where it led on how brains actually learn.

## The core distinction

Inductive learning fits a reusable function to labeled data and then applies it to any future point. Training uses the labeled examples once to set the model's parameters, after which the examples can be discarded and the formula kept. New points that arrive later are handled for free, by evaluating the same function.

Transductive learning does not build a reusable function. It takes a fixed, known-in-advance set of unlabeled points and labels those specific points by reasoning directly over the labeled and unlabeled data together. There is no standalone model to carry away, and a genuinely new point cannot simply be evaluated; it forces the computation to be redone.

## A concrete example

Setup: 1,000 product photos coming off a line, of which 50 are hand-labeled "defective" or "fine" and 950 are unlabeled. The goal is to label the 950.

The inductive way: train a classifier (logistic regression, say) on the 50 labeled photos. It fits a general decision boundary, a rule of the form `f(x) = σ(w·x + b)`. You then run each of the 950 through that rule. The rule is now a standalone object: throw away all 1,000 photos, keep the formula, and it will also label photo 1,001 tomorrow with no further work. The 950 played no part in shaping it.

The transductive way (label propagation): build one graph over all 1,000 photos, connecting each to its most visually similar neighbors regardless of label. Seed the 50 known labels and let them flow along the edges until every unlabeled photo settles on a label. The output is nothing but labels for those 950 specific photos. No rule was produced, and photo 1,001 means adding a node and rerunning the propagation.

## Transduction is not "distance to the labels"

The tempting misreading is that transduction simply measures how close each point is to the labeled ones. If that were all it did, it would be nearest-neighbor and nothing more. The defining feature is that it also uses the unlabeled points, as stepping stones. A label does not jump straight from a labeled point to a target; it hops point to point through the entire cloud. A target can therefore be labeled A because a dense chain of unlabeled points connects it back to an A seed, even when a B label is physically nearer in straight-line distance. This is the cluster (or manifold) assumption: nearby points along the data's own shape share labels, and the unlabeled mass reveals that shape.

## What it bets on, and how it breaks

When labels spread, both labels spread at once, like two dyes seeping in from opposite ends of the same string. Every unlabeled point goes to whichever label reaches it through shorter, denser connections, and the boundary forms where the two fronts meet. That meeting point lands at the sparsest part of the connection, the bottleneck, which is why a thin neck between two groups gives a clean, stable split.

This exposes the bet. Transduction, and semi-supervised learning in general, assumes the classes form clusters separated by low-density gaps. Fill a gap completely and evenly so that two groups become one uniform blob with no neck anywhere, and the method loses its footing: the boundary is no longer pinned, a few added points slide it around, and one label leaks across the smooth bridge into territory that should belong to the other. (This failure mode is called label leakage.) The construction that breaks it is exactly "bridge the two clusters with enough dots," because that erases the gap the whole method relies on.

The inductive formula does not fail in this particular way, because it never looked at the gap to begin with. But that same blindness is why it cannot exploit clean cluster structure when the structure is real. Each approach is a different bet about the world.

Vapnik's motivating principle for transduction: do not solve a harder, more general problem as an intermediate step toward the narrower one you actually care about. If you only need labels for these specific points, learning a full general rule first is solving more than the task requires, and the extra generality can cost accuracy when labels are scarce.

## Named methods

Most ordinary supervised learning is inductive: logistic regression, standard support-vector machines, decision trees, neural networks. The transductive family includes label propagation and label spreading, the transductive SVM, and graph-based semi-supervised methods generally. As a borderline case, k-nearest-neighbors and exemplar models are "lazy" (they keep the examples rather than compressing them into a formula) but still inductive, because they can answer any new query on demand. Semi-supervised learning is the broad family; transductive is the branch of it that refuses to build a reusable model.

## The key analytical distinction: re-compute versus re-adjudicate

Two operations are easy to merge and must be kept apart.

**Re-computing the boundary** means fitting it. For a large class of models this folds the past into a fixed-size summary and never revisits the individual points. Linear regression is the clean case: the best-fit line depends on the data only through five running totals.

```
b = (n·Σxy − Σx·Σy) / (n·Σx² − (Σx)²)
a = (Σy − b·Σx) / n
```

The individual coordinates appear nowhere on the right-hand side. When a new point arrives you bump each sum by that point's contribution and re-solve; the result is exactly identical to refitting on the whole dataset, and the old points are never read. This is recursive least squares, and the running mean (keep a sum and a count, update both) is the same trick with fewer sums. A quantity that summarizes the data losslessly for a given task is a sufficient statistic.

**Re-adjudicating** means deciding which side of the boundary each point is on. This is a per-point question over the whole population, and it has no sufficient statistic. When the boundary moves, not a single coordinate changes, yet every point's relationship to the line changes, and the points the line crosses get relabeled. The reason is that a label here is relational, not intrinsic: it is a property of the point's position relative to the current boundary, not something the point carries. Most shifts are too small to change a label, so they pass silently; only the near-boundary cases change hands.

Induction keeps these two operations separate. It re-computes a boundary from a summary without revisiting the dots, then re-adjudicates any point against that boundary individually and only when needed. That separation is precisely what lets an inductive model freeze (ship a fixed formula and walk away) and still generalize to points that did not exist at fit time.

Transduction fuses the two into a single joint solve over all the dots at once. There is no separate boundary that gets computed and then applied; the labels of the unlabeled points are defined by their relations to the other points, so solving for the layout and assigning the labels are the same act. That fusion is the source of every transductive property: there is no reusable model because the boundary never existed as a separable object, and a new point reopens the whole settlement because it changes the relations that defined every other point's label.

## The developmental synthesis

Pure transduction (a fixed, finite pile solved once, all at once) and pure induction (a stable summary plus an inert archive) are two idealized corners. The more accurate picture of learning a genuinely new domain is that the relational mode comes first and the boundary is a later achievement.

With three chairs, no boundary is licensed: infinitely many lines separate three points equally well, so committing to one is unjustified. What the evidence does support is the relational move, holding the few instances and comparing each new case against them ("like this, not like that, closer to this one"). That is a boundaryless judgment, which is transductive in form.

The boundary is emergent. It becomes available, and worth positing, only once the points are dense enough that a stable separating surface is actually implied by the data rather than invented on top of it. The "ah, there is a pattern here" moment is a phase transition: the instant the accumulated relational data crosses the threshold where a boundary is supported, one is abstracted, and with it come the separable line, generalization to the unseen, and the ability to stop consulting every past instance. That crystallization is the birth of induction out of a genuinely transductive ground state.

So early learning is not a weak inductive model running on scarce data. It is not an inductive model at all, because no line has been (or should be) drawn. It is exemplar-relational: keep instances, judge new ones against the ones held, accumulate, and abstract a boundary only when density makes the line defensible. One refinement: the infant version is not the batch transductive algorithm (a closed pile re-solved each time) but its online, open-ended cousin, essentially the exemplar model placed correctly in time, as the first phase rather than as a rival to induction.

## Is there a biological analogue to transduction?

Not "none." Local episodes have the right shape: walking into an unfamiliar room and sorting out who is with whom and who is senior, read entirely off the people in relation to each other, with no prior model of these specific individuals and no portable formula carried away. The judgments are mutually defined and computed jointly over one fixed set. That is transductive in form, so the operation is in the repertoire.

But the brain rests in neither idealization, and the reason cuts both ways. Textbook induction assumes an inert archive of stable past points that the new boundary is cleanly applied against. Memory does not work that way. Recall is reconstruction, not retrieval: revisiting a trace rebuilds it in the present's terms and re-stores the rebuilt version (reconsolidation), so there is no pristine original sitting underneath, and the "dots" do not hold still. The human version of induction therefore lacks the clean separation that defines the textbook version, because re-adjudication bleeds back into the substrate.

The conclusion is that transduction and induction are both fixed-point idealizations, and the brain is the system that never reaches a fixed point. It is relational like transduction (meaning is read off neighbors and context, not from a context-free rule), generalizing like induction (it applies a sense to the genuinely unseen without re-solving the world), and continually self-revising in a way that corrupts the stable substrate both idealizations assume. It borrows the relational, solve-together character in the moment and the generalizing, carry-forward character across time, while rewriting the very traces each idealization treats as standing still. So there is no clean biological analogue to transductive learning for the same reason there is no clean biological analogue to inductive learning.

## Connection to the neural-network thread

The artificial neuron, by construction, drops time, drops spikes, and drops the constant rewriting, buying clean and separable operations at the cost of the freeze: train, lock the parameters, apply the result from then on. The brain keeps all of it and refuses the freeze, and pays by never having a stable past to stand on. Transduction, like induction, is one of the clean shapes that a system without a stable substrate can pass through but never hold.
