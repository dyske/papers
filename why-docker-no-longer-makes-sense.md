# Why Docker Containers No Longer Make Sense for AI-Driven Application Development

## The Premise: Where AI-Driven Development Is Heading

This argument starts from a directional view of where software development is going, not where it is today. The infrastructure choices that make sense depend entirely on which trajectory you believe is real.

### 1. AI handles technical execution; humans hold vision

The historical bundle of "software developer" — someone whose value came from knowing the language, the framework, the platform, the patterns — is unbundling. Technical expertise that used to require years of specialization is now retrievable on demand from AI with better recall and broader coverage than any individual could maintain. What remains scarce is not execution capacity but **vision**: knowing what to build, understanding the user, making judgment calls about direction.

This is the Steve Jobs model, generalized. Jobs couldn't write the code for the Mac, but his clarity about what the product should be shaped it more than any individual engineer's contribution. As AI capability rises, this pattern becomes available to more people for more kinds of projects.

### 2. The optimal team size is shrinking toward one

Once technical execution is delegated to AI, the marginal value of additional human developers collapses. Human-to-human coordination is expensive — every additional person introduces sync meetings, alignment overhead, and decision-by-committee dynamics that dilute vision. A solo director with AI doesn't move at "half the speed of two people" — they often move 3-5x faster than a two-person team would on the same problem, because there is no coordination tax at all.

Multi-person teams also suffer from a structural problem in the AI era: when execution is cheap, debate becomes obsolete as a substitute for trying things. The committee model — argue first, build second — made sense when execution was expensive. When execution is free, the team's deliberations actively slow down the feedback loop with reality.

Vision purity matters too. A single mind produces a coherent product. A committee produces the convex hull of acceptable compromises, which is no one's best idea, and which can't be learned from when it fails because no one was actually betting on what shipped.

### 3. Speed dominates quality

In an environment with cheap execution and high uncertainty, **iteration speed is itself a quality dimension**. A product that ships in two weeks and gets iterated 20 times based on real usage is structurally better than a product that ships in six months as a polished v1, because the iteration loop has touched reality 20 times instead of zero.

This inverts the traditional cost-benefit of slow, careful pre-execution work. The team-of-directors version doesn't just produce a slightly-better v1 slightly later — it produces a worse product overall because it has fewer reality-contact cycles.

### 4. AI agents handle operations, not just coding

AI is not just writing the code — it is provisioning infrastructure, debugging production, and managing operations. AI agents can SSH into hundreds of VMs in parallel, hold all of them in working context, and don't get fatigued by heterogeneous environments. The operational ergonomics that humans need (standardization, uniform interfaces, consolidated logging) are not constraints for AI.

### 5. Infrastructure provisioning is now near-instant

Spinning up an EC2 instance with full network and security configuration takes seconds via AWS CLI driven by an AI agent. Cloud dev environments accessed via SSH Remote (Cursor, VS Code) are now superior to local development for most projects — right-sized hardware per project, no dev/prod OS drift, easy teardown, shareable with a teammate, auto-shutdown when idle.

---

## Why Docker Containers Stop Making Sense Under These Assumptions

If the assumptions above hold, every classical benefit of containerization either disappears or becomes net-negative.

### Reproducibility across dev machines — irrelevant

The use case for "works on my Mac and on Linux prod" assumed a team of developers with heterogeneous local environments. With a solo director using a cloud-based development VM that can itself be a snapshot of production, there is no environment drift to solve. The reproducibility problem containers were designed for has been solved by a different mechanism.

### Bin-packing services onto shared hardware — trivial savings

Multiple containers on one VM saves money. But the savings are small (tens to hundreds of dollars per month) compared to the opportunity cost of slower development (hours per week of a solo director's time). For anyone whose time is worth more than minimum wage, this trade is a clear loss.

### Dev/prod parity — partially illusory

Containers give you byte-identical *images*, but not byte-identical *configurations*. Production has different secrets, different network topology, different scale, different data, different IAM roles, different traffic patterns. The container solves the easy part of dev/prod parity (the binary) while doing nothing for the hard part (everything around it). Production-only bugs still happen — and now they happen inside a container abstraction layer that adds indirection to debugging.

### Isolation — VMs do it better

Containers are a weaker security and stability boundary than VMs in essentially every dimension. If isolation is what you need, one-app-per-VM is strictly better than one-app-per-container.

### Operational standardization for humans — not needed for AI

Containers partly exist as a **human ergonomics technology**. They standardize the operational surface — same `docker logs`, same `kubectl exec`, same patterns across services — to reduce cognitive load on human SREs. AI agents don't need this. They can manage 100 different VMs with 100 different configurations without strain, and they actually benefit from **direct access to the real running system** (real process tree, real filesystem, real network stack) without an abstraction layer between them and the thing that's broken.

### The deployment tax

Containerized deployments routinely take 10+ minutes per cycle. In an early-stage AI application where deploying 10 times a day is normal, that is 100+ minutes per day of dead time on the CI/CD pipeline. Direct deployment to a VM — rsync, systemd restart — is seconds. Over a year of development, the compounded time cost of containerization is enormous, and it compounds against the resource you're most trying to protect: iteration speed.

### GPU sharing

GPUs are the one hardware resource still worth sharing because of cost. But Docker containers cannot share GPU compute dynamically in the simple case — each container gets a fixed allocation, and unused capacity in one container is unavailable to others. Two processes running directly on the host VM can both access 100% of the GPU as needed. (NVIDIA MPS and MIG exist, but they add their own configuration complexity that defeats the simplicity argument for containers.)

### Debugging overhead for AI agents

This may be the most underweighted point. When the troubleshooter is an AI agent, every layer of indirection multiplies the debugging surface. Is the bug in the app, the container, the orchestrator, the host, or the interaction between them? For a human, this indirection is annoying. For an AI agent running rapid iteration cycles, it's a tax on every debugging session — and debugging is where most development time actually lives, not in writing new code.

---

## The Conclusion

Containers were a solution to a specific set of problems:

- Heterogeneous developer environments
- Multi-tenant hardware utilization for cost savings
- Large-team coordination requiring operational standardization
- Human SRE ergonomics

**Every one of these problems is dissolving in the AI-development context.** When the problems go away, the solution becomes overhead.

For the solo director building an AI application with AI agents handling execution and operations:

- One app per VM
- Direct deployment via scripts or systemd
- Cloud-based dev environment via SSH Remote
- AI agents manage the fleet directly, without a container abstraction layer

The stack ends up looking much more like 2005 (processes on VMs, SSH for ops, scripts for deploys) than like 2020 (Kubernetes, service mesh, GitOps). The 2020 stack was optimizing for a coordination problem — many humans, many services, many environments — that AI is dissolving.

## Caveats

This argument applies cleanly to:

- Solo or near-solo development
- Early-stage AI applications
- Projects where the cost of being wrong is recoverable through iteration
- Workloads where speed dominates polish

It does not apply (or applies with significant qualification) to:

- Teams of more than a few people who still need shared operational primitives
- Safety-critical or regulated systems where slow, careful pre-execution work is mandatory
- Complex distributed systems with genuine multi-tenant requirements
- Workloads where the irreversibility of mistakes makes fast iteration dangerous

The skill is recognizing which situation you're actually in. For a large and growing class of AI-driven projects, the situation has changed enough that the default — "of course you containerize" — is no longer the right default. The burden of proof has flipped.
