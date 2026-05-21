# Software As a Company (SaC) DevOps for the AI Era

## Premise

The SaC architecture document describes what gets built and how the system is structured. This document is its operational and governance companion. It describes who builds the system, what infrastructure they consume, and how the company keeps control without becoming the bottleneck.

The same economic shift drives both. AI collapses the cost of building software, which is what the architecture document is about. AI also collapses the cost of provisioning infrastructure, deploying services, reading logs, and diagnosing incidents. When both costs collapse, the binding constraint stops being engineering capacity and becomes governance: who is allowed to build what, with which tools, against which data, at what cost, with what auditability. Without governance, AI-collapsed cost just means everyone provisions everything everywhere and the company becomes ungovernable in no time. With governance, the same cost collapse means the company finally has the operational fluency to match its business velocity. It is DevOps redesigned around the assumption that **most people building production systems are not professional engineers**, that **AI agents do most of the actual work**, and that **the company's leverage point is the curation and governance of the substrate**.

---

## Core Principles

1. **Governance is the binding constraint, not engineering capacity.** AI collapses the cost of building, provisioning, deploying, and operating. What still scales linearly with humans is coordination, curation, and audit. Therefore the company's leverage shifts from "what can we build" to "what should we let people build, and how do we keep it coherent."
2. **AI Builders are first-class.** The platform is designed for non-engineers building production systems with AI assistance. Engineers also use it; the design center is the AI Builder, not a limited subset of an engineering platform.
3. **One door.** All infrastructure provisioning, modification, and decommissioning happens through the DevOps Console. The AWS Console is reserved for emergency platform-engineering work and is logged when used. The discipline of "everything is auditable" requires "everything goes through the audited surface."
4. **Agent-fluency over human ergonomics.** Technology choices are governed by how well AI agents understand them, not by what feels comfortable to people. A small set of well-trained tools beats a wide set of well-loved ones, because the productivity gain compounds across every AI Builder in the company.
5. **Risk is the access axis, not seniority.** Permissions are scoped by role × project × environment, not by employee level. A senior engineer working on a high-risk customer-facing system may have less permission than a junior AI Builder working on an internal tool.
6. **Compute is rented by the minute.** No always-on dev machines. No always-on idle resources. The cost of capacity approaches zero; the cost of usage is what matters.
7. **The laptop is a dumb terminal.** Source code never leaves the company VPC. Local machines are throwaway; dev environments are remote, ephemeral, and reproducible from a runbook. Any laptop, any OS, any vintage, anywhere in the world.
8. **Centralize the management plane; never the data plane.** Each skill owns its own database, its own data, its own boundaries. What's centralized is how everything is provisioned, monitored, and governed, not the data itself.
9. **AWS is the chosen lock-in.** The agent-fluency argument settles the cloud choice. We accept the lock-in explicitly because the AI-Builder-productivity gain from a single-cloud, agent-fluent stack outweighs the optionality cost.
10. **Deprovisioning is as important as provisioning.** Every resource has an owner, an expiry, and a retirement workflow. Without active deprovisioning, the AWS account becomes a wasteland overtime.

---

## The Architecture

```text
┌────────────────────────────────────────────────────────────────────────────┐
│  AI BUILDERS  ─  laptops are dumb terminals; nothing dev-related lives on  │
│                  them; everything happens in AWS                            │
│                                                                             │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐                                            │
│  │ Mac │ │ Win │ │ Mac │ │ ... │  ← any OS, any vintage, anywhere           │
│  └──┬──┘ └──┬──┘ └──┬──┘ └──┬──┘                                            │
│     └──────┴───────┴───────┴────────┐                                       │
│                                     │  SSH (Cursor / VS Code Remote)         │
│                                     │  HTTPS (DevOps Console)                │
└─────────────────────────────────────┼──────────────────────────────────────┘
                                      ▼
┌────────────────────────────────────────────────────────────────────────────┐
│  DEVOPS CONSOLE  ─  the only door into AWS for AI Builders                  │
│                                                                             │
│  ┌─────────────────┐ ┌──────────────────┐ ┌────────────────────────┐       │
│  │ Runbook catalog │ │ Health dashboard │ │ Audit + cost ledger    │       │
│  │ (tier-1 stack)  │ │ (LLM triage)     │ │ (immutable, queryable) │       │
│  └─────────────────┘ └──────────────────┘ └────────────────────────┘       │
│                                                                             │
│  Provisioning · monitoring · access control · cost guardrails · retirement  │
└────────────────────────────────────────┬───────────────────────────────────┘
                                         ▼
┌────────────────────────────────────────────────────────────────────────────┐
│  AWS  ─  the substrate the company actually runs on                         │
│                                                                             │
│  ┌─── Dev VMs ──────┐  ┌─── Per-skill VMs ─┐  ┌─── Managed data ──────┐    │
│  │ EC2 + EBS        │  │ EC2 + systemd     │  │ RDS · ElastiCache ·   │    │
│  │ auto-shutdown    │  │ (per sac-arch.md) │  │ OpenSearch · S3       │    │
│  └──────────────────┘  └───────────────────┘  └───────────────────────┘    │
│                                                                             │
│  ┌── Observability ──┐  ┌─── Identity / Access ──┐                          │
│  │ CloudWatch · OTel │  │ IAM · permissions      │                          │
│  │ CloudTrail        │  │ boundaries · SCPs      │                          │
│  └───────────────────┘  └────────────────────────┘                          │
└────────────────────────────────────────────────────────────────────────────┘
```

The DevOps Console is itself a SaC kernel-level skill. It runs on the same architecture as everything else. AI Builders interact with it through a web UI; AI agents interact with it through MCP. The Console is the only thing in the company with broad AWS provisioning permissions; every other identity in AWS has narrower, role-scoped permissions issued by the Console.

---

## Roles

Three roles structure the operational model. Each interacts with the Console differently and has different powers.

### AI Builder

The design center of the platform. Most AI Builders are not professional engineers; they are operations, finance, sales, clinical, or any other functional role whose work has been shaped by AI into something resembling software development. They build skills the company needs by collaborating with AI agents, using the Console to provision the infrastructure those skills require.

An AI Builder does not log into the AWS Console, does not write IAM policies, does not pick frameworks unilaterally, does not configure load balancers. They click a runbook, fill in a form, and the Console provisions a tier-1 stack against their permission scope. They write skill code (with AI assistance) on a remote dev VM the Console provisioned for them. They deploy with a single click that runs the deploy runbook bound to their project.

The platform's job is to make this safe by default. An AI Builder cannot accidentally expose customer data, blow a budget, or violate a compliance constraint, because the Console refuses to provision anything that would cause those outcomes.

### DevOps Engineer

DevOps engineers build and maintain the DevOps Console itself, author the runbook catalog, define the access tiers, curate the technology stack registry, and respond to incidents the Console cannot resolve automatically. They have direct AWS access for emergency work; that access is logged to the same audit ledger every other action goes through.

### Security and Compliance

One person at company scale defines the permission boundaries, the SCPs at the AWS Organizations level, the data classification rules, the retention policies, and the audit-review cadence. Reviews the Console's audit ledger periodically.

Security and compliance does not provision anything directly. They define the rails the platform engineers implement and the Console enforces.

---

## The DevOps Console

The Console has four surfaces. Each one corresponds to one of its primary jobs.

### Runbook catalog

The provisioning surface. A grid of tiles, each tile a parameterized template that produces a coherent stack of AWS resources. Examples (in the order they probably get built):

- **Next.js + RDS Postgres** — one EC2, one RDS, ALB in front, CloudFront, route53 record, ACM cert, basic CloudWatch dashboard. Framework already installed and connected to the database. One click for the AI Builder; ~3 minutes wall-clock to provisioned.
- **Python service + RDS Postgres** — same shape, FastAPI on uvicorn under systemd, no framework HTML.
- **Static site on S3 + CloudFront** — the cheapest tile. For documentation, internal landing pages, marketing sites.
- **Remote dev VM** — sized as small / medium / large / GPU; choose Ubuntu LTS or Amazon Linux; auto-shutdown configured.
- **MCP sidecar for an existing skill** — Python FastAPI on `sac-mcp-base`, paired to the skill's REST URL.
- **Background worker** — second systemd service alongside an existing skill's main service, queue-table consumer, deploy-bound to the same skill repo.
- **Skill bootstrap (greenfield)** — full skill scaffold: VM, RDS, MCP sidecar, openapi.yaml stub, ops/ directory, systemd unit, deploy.sh.

Each tile is a curated bundle, not a free-form configurator. The AI Builder fills in a project name, picks an environment (dev / staging / prod), and the Console does the rest. Parameters are minimal and opinionated. If the bundle does not fit, the AI Builder petitions the platform engineers to add a new tile, who add it once for everyone.

### Health dashboard

The observation surface. For each project the AI Builder has access to, the Console shows current resource state, recent error rates, recent deploys, current cost burn, and any active alerts. The AI Builder can drill into logs without leaving the Console, CloudWatch is the source of truth, but the Console renders it with project-scoped filters and LLM-assisted summarization.

When an alert fires (an HTTP 5xx spike, a failed deploy, an OOM kill, a budget threshold), the Console captures the relevant log slice, asks an LLM to produce a ranked list of likely causes, and notifies the project's owner.

The dashboard is intentionally project-scoped. AI Builders see their own projects and the projects they have read-access to. The devops engineers and security/compliance see everything.

### Audit and cost ledger

The accountability surface. Every Console action, every provision, every destroy, every permission grant, every alert acknowledged, every emergency AWS Console use by a platform engineer, produces one row in an immutable, queryable audit log.

Cost is the same surface. Every dollar AWS bills is attributed to a project (via tags the Console enforces), to an environment, and to an owner. Cost queries are first-class on the same ledger: "what did `proj-foo` cost last month, broken down by service" is a one-line query and a saved dashboard. Spend trends, budget breaches, and cost-anomaly alerts are all derived from this ledger.

### Access management

The permissions surface. For each AI Builder, the Console shows their current role, their project assignments, their environment access per project, and their effective IAM permissions. New project assignments are issued from this surface with a small form (project, environment, tier). When an AI Builder leaves or rotates, deprovisioning is one click and runs a workflow that ends every active session, rotates secrets they had access to, and marks their projects for owner-handoff.

The devops engineers and security/compliance use this surface to assign and audit; the AI Builder uses it only to view their own access.

---

## Access Model

Permissions are the most consequential thing the Console manages. The default reflex is to scope by employee seniority but seniority is the wrong axis. The right axis is **risk**: blast radius if the action is wrong, multiplied by the value of the data or system being touched.

### The three axes


| Axis            | What it captures                          | Example                                                           |
| --------------- | ----------------------------------------- | ----------------------------------------------------------------- |
| **Role**        | What the person does in the company       | AI Builder, platform engineer, compliance reviewer                |
| **Project**     | Which skill or system they are working on | `proj-billing`, `proj-customer-portal`, `proj-internal-wiki`      |
| **Environment** | Dev, staging, or prod                     | The same project has three permission scopes, one per environment |


A specific permission is the intersection: "AI Builder, on `proj-internal-wiki`, in dev." The Console resolves that intersection to a concrete IAM permission set at provision time. The AI Builder never sees an IAM policy document; they see "you can provision in this project's dev environment."

### Tiers

Within an environment, the AI Builder is assigned a tier that bounds what they can do. Five tiers cover the company's needs:


| Tier                                     | Scope                                               | Typical use                                                  |
| ---------------------------------------- | --------------------------------------------------- | ------------------------------------------------------------ |
| **T0 — Read only**                       | Browse runbooks; read project dashboards            | Auditors, observers, new hires before training               |
| **T1 — S3 prefix**                       | Write to one S3 prefix; nothing else                | Light tooling, one-off data work, training sandboxes         |
| **T2 — One project, dev**                | Provision and operate one project's dev environment | The most common AI Builder tier                              |
| **T3 — One project, all environments**   | Promote to staging and prod                         | Project owner; takes responsibility for the project          |
| **T4 — Project group, all environments** | Multi-project owner                                 | Senior AI Builder running a domain (e.g. all finance skills) |
| **T5 — VPC**                             | Anything within a dedicated VPC                     | Platform engineer; rare, project-by-project, time-boxed      |


The tier is not a property of the person. The same AI Builder may be T3 on one project and T1 on another. New projects start the owner at T3 and other contributors at T2; promotions to higher tiers require security/compliance sign-off and are recorded in the audit ledger.

---

## Agent-Fluency

Technology choices are governed centrally. The principle: **AI agents are the dominant labor that operates company technology, so technology choices are made for them, not against them.** A framework an agent has seen ten thousand times in training is more productive than a framework an engineer prefers but the agent has seen ten times.

This is the operational expression of the architecture document's stack-recommendations table. The architecture doc states the policy ("TypeScript by default; Python where ML lives; PostgreSQL one per skill; ..."); the Console enforces it.

### The technology stack registry

A central, versioned list of every technology the company uses, organized in three tiers:


| Tier                                 | Meaning                                                                                                        | Console behavior                                                                         |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| **Tier 1 — Universal**               | Default choices. Strong agent fluency. Used unless a stated reason exists not to.                              | Visible in every relevant runbook menu. Selected by default.                             |
| **Tier 2 — Justified**               | Acceptable for specific use cases where Tier 1 does not fit. Requires written justification at provision time. | Visible behind a "Show alternatives" expand. Logs the justification to the audit ledger. |
| **Tier 3 — Restricted / deprecated** | Forbidden by default. Requires explicit per-project approval from security/compliance.                         | Hidden from menus. Flagged as a violation if found in any provisioned resource.          |


### What Tier 1 looks like

Mirroring the architecture document's stack table:

- **Web service runtime**: TypeScript on Bun, Hono framework
- **ML / data service runtime**: Python 3.12, FastAPI, Pydantic v2, uv
- **Compute-heavy runtime**: Rust + Axum (only when measurable perf demands)
- **Database**: RDS PostgreSQL 16+
- **Cache / KV**: ElastiCache (Valkey or Redis)
- **Search**: AWS OpenSearch
- **Object storage**: S3
- **Background queue**: PostgreSQL `FOR UPDATE SKIP LOCKED` (Procrastinate / pg-boss / River depending on language)
- **Real-time gateway**: Centrifugo
- **Observability**: OpenTelemetry SDKs to CloudWatch
- **MCP**: Python FastAPI sidecar on `sac-mcp-base`

Tier 2 candidates exist for cases like high-throughput analytics (ClickHouse), specialized ML inference servers (vLLM, Triton), workflow engines (Temporal, Inngest), and similar. Tier 3 is the explicit deprecation list — frameworks the company used to use but no longer wants.

---

## The Runbook Catalog

A runbook is a parameterized, versioned, signed template that produces a coherent set of AWS resources. The catalog is what the Console exposes to AI Builders; the runbooks themselves are what platform engineers maintain.

### Anatomy of a runbook

Every runbook has the same shape:

```text
runbooks/
  nextjs-rds/
    runbook.yaml           # metadata: title, description, tier, parameters
    main.tf                # Terraform module that produces the resources
    bootstrap.sh           # post-provision setup: install framework, seed config
    teardown.sh            # graceful destroy, including data archival prompts
    README.md              # what this runbook produces, what it costs, what it does not cover
    tests/
      smoke_test.sh        # runs after provision, validates the stack came up
```

The `runbook.yaml` is what the Console reads to render the tile. It declares parameters with types and validation, the tier-1 technologies the runbook uses, the cost estimate per environment, the supported environments, and which roles/tiers are allowed to invoke it.

Runbooks are not added "in case someone wants this." Every runbook in the catalog has a stated owner and is retired if usage drops below a threshold. A small, sharp catalog is much better than a sprawling one.

---

## Remote Development

Development happens on remote dev VMs in AWS. Local laptops are dumb terminals connected via SSH (Cursor Remote, VS Code Remote-SSH, or the equivalent). Source code never lives locally.

### Why remote development is the default

Five reasons converge:

1. **IP protection.** Source code never leaves the company VPC. A laptop walking out the door has nothing on it. A subpoena to a former employee's personal device finds nothing.
2. **Onboarding speed.** A new AI Builder gets productive within minutes of provisioning a dev VM. No "install Postgres, install Node, install Python, configure your editor" walk-through.
3. **Reproducibility.** Every dev VM is provisioned from a runbook, so every environment is identical. "Works on my machine" stops being a sentence anyone says.
4. **Compute flexibility.** Need a GPU? Provision a GPU VM. Need 64 GB RAM for a data import? Provision a large VM. Done with the work? Auto-shutdown reclaims the capacity. No one has a $4000 laptop sitting idle.
5. **AI-agent fluency.** Agents run on the dev VM alongside the developer; they share the same filesystem, the same git state, the same processes. No local-vs-remote mismatch to reason about.

### Sizing and OS choice

The dev-vm runbook offers four sizes — small (2 vCPU, 8 GB), medium (4 vCPU, 16 GB), large (8 vCPU, 32 GB), gpu (whatever the project needs) — and two OSes — Ubuntu 24.04 LTS, Amazon Linux 2023. Other sizes or OSes require a petition. Size can be changed mid-project; OS cannot, because the deltas are not worth the support surface.

### Shared vs per-user

Each AI Builder gets their own dev VM by default. VMs are cheap; coordination problems are not. When multiple people genuinely need the same machine (a shared GPU box for collaborative ML work, a shared database for joint debugging), the runbook offers a "shared" mode that provisions per-user systemd services, per-user tmux sessions, and per-user port allocations on a single underlying VM. The default remains per-user.

### Auto-shutdown

Dev VMs auto-shutdown after a configurable idle period (default: 30 minutes of no SSH activity, no active processes above a CPU threshold, no recent file modification). Auto-startup happens on the next SSH connection — the runbook attaches a small wake-on-connect proxy that issues `aws ec2 start-instances` when an SSH attempt arrives, with an acceptable five-to-ten-second startup latency.

The auto-shutdown logic has two escape hatches:

1. `**keepalive` flag** the AI Builder sets when starting a long job, automatically expires after the job's expected duration plus buffer.
2. **Background-job exception** for processes tagged with a known long-running label (training runs, batch indexes), which suppress shutdown until they exit.

The economics: a medium dev VM at 8 hours/day of active use costs about $30/month. Always-on it would cost about $90. At company scale (twenty-to-thirty AI Builders), auto-shutdown saves several thousand dollars per year. More importantly, it makes "spin up a separate dev VM per project" the default, because per-VM cost is dominated by usage rather than by capacity.

### Why this means Docker is optional in development

Containers exist to isolate environments on shared hosts. If every project gets its own dev VM, the VM is the isolation. The AI Builder runs Postgres directly on the VM, runs the application directly on the VM, runs the agent directly on the VM. No `docker-compose up`, no volume mounts, no port forwarding, no `host.docker.internal`.

This matters because AI agents struggle with Docker. The mental model, file in container, file on host, port in container, port on host, network namespace, volume permissions, is one of the most error-prone surfaces in their training data. Removing it removes a significant source of agent confusion. The deployment story for production also has no Docker (per the architecture document's VM-Native Deploy Model), so dev and prod stay symmetrical.

### Local-laptop as dumb terminal

Any laptop, any OS, any vintage. A new hire is productive on day one with a five-year-old MacBook from a hardware closet. A breakage means a new laptop, not a new development environment. Work-from-anywhere is structurally enabled, not merely tolerated. A traveling AI Builder on hotel WiFi has the same dev environment as a home AI Builder on fiber.

The friction point worth naming: bandwidth. SSH-based dev is fine on good connections, slower on bad ones. Cursor's remote file ops introduce noticeable latency over high-RTT links. Heavy operations (large repo clones, big test suites, build watchers) want either a fast link or a generously-sized dev VM that absorbs the work without round-tripping. This is mitigated, not eliminated, by good caching and pre-built AMIs.

---

## Centralized Observability

Logs, metrics, and traces are centralized in CloudWatch. Every skill, every dev VM, every Console action, every AWS service emits to one observability plane. The Console reads from that plane; AI Builders read from the Console.

### What gets emitted

- **Application logs** — every service's stdout/stderr is streamed to CloudWatch Logs via the CloudWatch agent on the VM. JSON-structured by default; the structure mirrors the SaC `audit-envelope.md` shape so application logs and audit events are queryable in the same syntax.
- **Metrics** — per-service application metrics via OpenTelemetry SDKs to the CloudWatch metrics API. Standard metrics (request count, request duration, error rate) are uniform across all skills because the `sac-mcp-base` library and the equivalent REST middlewares emit them automatically.
- **Traces** — OpenTelemetry traces with W3C trace context propagation across REST → MCP sidecar boundaries. Tracing is sampled aggressively (most traces dropped) but always-on for error responses.
- **AWS service logs** — CloudTrail for API calls, VPC flow logs for network, ALB access logs, RDS slow query logs, all flowing into CloudWatch.
- **Audit ledger** — every Console action emitted as a SaC audit envelope to a dedicated CloudWatch log group with a long retention policy.

### LLM-driven diagnosis

When an alert fires, the Console captures the relevant slice, the last N seconds of application logs, the recent metric trajectory, the last deploy diff, the active configuration, and runs it through an LLM with a structured-output prompt. The LLM returns a ranked list of likely causes, each with a confidence label, the evidence it relied on, and a suggested next diagnostic step.

The output is treated as a draft hypothesis, never a verdict. The notification to the project owner reads "the system thinks this might be X; here is the evidence." The owner agrees or disagrees and acts; their action is captured to refine future diagnoses. Over time, the catalog of "we've seen this shape before, last time it was Y" becomes a real asset.

Three honest limits:

1. **The LLM is wrong sometimes.** A confident-but-wrong diagnosis can send the owner down the wrong path. The mitigation is to surface multiple ranked hypotheses, not a single answer; to require human confirmation before any automated remediation; and to track diagnosis accuracy over time so the calibration is visible.
2. **Novel failures are still hard.** Patterns the LLM has seen (OOM kills, connection-pool exhaustion, deploys gone wrong, certificate expiries) are diagnosed well. Genuinely novel failures still require human investigation.
3. **The cost of running the LLM on every alert is real.** Cost guardrails apply: rate-limit per project, cap monthly LLM-diagnosis spend per project, fall back to "captured evidence + no LLM analysis" when the cap is hit.

### What the dashboard looks like

A project dashboard has four panels, in this order:

1. **Service health** — green/yellow/red per service, computed from error rate and latency SLOs.
2. **Recent activity** — last five deploys, last five alerts, last five Console actions.
3. **Cost** — month-to-date burn, projected month-end, comparison to budget.
4. **Open issues** — alerts not yet acknowledged, plus open security findings, plus stale resources.

Drilling into any panel opens the underlying CloudWatch query in a Console-rendered view. The AI Builder never has to context-switch to the AWS Console to investigate.

---

## Centralized Data Services

Databases are centralized in RDS. Cache layers are centralized in ElastiCache. Search is centralized in OpenSearch. Object storage is centralized in S3. Self-hosted alternatives are not in Tier 1.

### Why centralize

Three reasons:

1. **Governance.** Data classification rules (PII, PHI, financial) apply uniformly across every database when every database is the same managed service in the same VPC topology. Data leakage detection — flow logs, access patterns, query audit — works consistently across the fleet.
2. **Operational uniformity.** Backup, point-in-time recovery, encryption-at-rest, encryption-in-transit, parameter tuning, version upgrades, and CVE response are one set of runbooks instead of one set per skill author. Platform engineering can guarantee these properties because RDS guarantees them.
3. **Agent fluency.** AI agents reason about RDS PostgreSQL fluently. They reason about a self-hosted Postgres on a custom VM less fluently. They reason about MariaDB on RDS less fluently. The agent-fluency principle says: pick the substrate the agents know best, and stick to it.

### Data access governance

Reading data across project boundaries requires explicit grants, recorded in the audit ledger. The Console exposes a "request data access" workflow for cases where an AI Builder needs to query another project's database (research, debugging, analytics). The grant is time-boxed, optionally redacted (read-only, specific tables, specific columns), and reviewed by the data owner.

The default is no cross-project read access. The exception requires a workflow. Without this discipline, "centralized in RDS" becomes "everyone can see everything," which is the worst of both worlds.

---

## Lifecycle

Every resource has four lifecycle events: provision, modify, alert, retire. Provisioning is the most-discussed event but retirement is where companies actually fail.

### Provision

Initiated through a runbook in the Console. Parameterized, validated, signed, audited. The Console computes a cost estimate before provisioning and refuses provisions that exceed the project's budget headroom. After provisioning, the smoke test runs; failures roll back automatically.

### Modify

Resource modifications go through the Console, not through `aws` CLI sessions. The runbook that provisioned a resource also defines the legal modifications: a Next.js+RDS runbook supports "scale up the EC2," "scale up the RDS," "add another availability zone," "rotate database password." Modifications outside the legal set require a runbook update or a petition.

This is more restrictive than what AI Builders may be used to. The trade is: the Console can guarantee cost, audit, and compliance properties only for modifications it understands. A free-form `aws` CLI session against the resource breaks that guarantee.

### Alert

Alerts come from CloudWatch alarms, from cost anomaly detection, from security findings, from health checks. The Console routes them, runs LLM-assisted diagnosis, and notifies. Acknowledged alerts are recorded; unacknowledged alerts after a threshold escalate.

### Retire

The retirement workflow is initiated when a project is decommissioned, an experiment ends, or a resource ages past its tagged expiry. The workflow:

1. **Tagging audit** — find every resource tagged with the project ID.
2. **Data classification check** — identify databases, S3 prefixes, and log groups; route them through the data-archival path appropriate to their classification.
3. **Dependency check** — identify cross-project dependencies (a shared VPC, an SQS queue another project consumes); refuse retirement until dependencies are resolved.
4. **Decommission** — invoke the runbook's `teardown.sh` which destroys resources in dependency order.
5. **Cleanup** — remove DNS records, remove ACM certs, rotate any secrets, expire any IAM grants.
6. **Audit** — record every action to the audit ledger; produce a retirement summary report.

Without active retirement, resources accumulate. Every quarter, the Console runs a stale-resource scan and surfaces candidates for retirement: VMs not connected to in 60 days, RDS instances not queried in 30 days, S3 buckets not written to in 90 days, route53 records pointing at terminated EC2s. The owner reviews and confirms.

This is the single most important operational discipline. Companies that do everything else right and fail to retire end up with thousand-dollar-a-month AWS bills for systems no one remembers building.

