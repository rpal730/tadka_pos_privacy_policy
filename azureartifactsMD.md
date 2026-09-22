# How Azure Artifacts works

Private package feeds, and the rules that govern them.

September 2026

---

## A feed is a private package registry

It behaves like nuget.org or npmjs.com, except you decide who publishes and who consumes.

### What a feed gives you

- One registry for npm, NuGet, Maven, Python, Cargo, and Universal Packages
- A place to publish internal packages and control who can pull them
- A cache of public packages, so an outage upstream does not stop your build
- Version immutability. Once published, that version number is reserved for good

### What it is not

- Not pipeline artifacts, which are build outputs attached to one run
- Not pipeline caching, which only speeds up restores inside a pipeline
- Not general file storage. Every package counts against your quota
- Not a replacement for source control

*A single feed can hold all six package types at once. Most teams need far fewer feeds than they think.*

---

## Publish once, resolve from one place

The same four moves whether the package is yours or came from a public registry.

**1. Publish**
A pipeline or a developer pushes a package version to the feed. That version number is then reserved permanently.

**2. Store**
The feed holds it in the `@local` view, alongside anything saved from upstream sources.

**3. Authenticate**
The consuming pipeline runs `NuGetAuthenticate`, `npmAuthenticate`, or `PipAuthenticate` to get a token.

**4. Consume**
`restore` or `install` resolves from the feed first, then from its upstream sources in order.

*Resolution order matters: packages published directly to the feed win, then copies already saved from upstream, then the upstream registries themselves.*

---

## Four settings decide how a feed behaves

Get these right at creation. Changing them later is disruptive.

**01. Scope**
Project scoped feeds are visible only inside the hosting project. Organization scoped feeds are visible across all of them. Start project scoped.

**02. Views**
Every feed ships with `@local`, `@prerelease`, and `@release`. Promote a version through them as it clears your quality gates.

**03. Upstream sources**
Point the feed at nuget.org or npmjs.com. The first install by a collaborator saves a copy into the feed permanently.

**04. Retention**
Set a version count limit and a download protection window on day one. Storage creeps up quietly otherwise.

---

## The numbers and limits worth knowing

The parts that surprise teams after the first few months.

| | |
|---|---|
| **Package types** | npm, NuGet, Maven, Python, Cargo, and Universal Packages, all in one feed. |
| **Free storage** | 2 GiB per organization. Beyond that, billing is per GiB consumed. |
| **What counts** | Every package, including copies saved from upstream sources. |
| **What does not** | Pipeline artifacts and pipeline caching do not contribute to storage charges. |
| **Recycle bin** | Deleted packages sit there for 30 days and still count until removed. |
| **Over the limit** | Without billing set up, exceeding 2 GiB drops the feed to read only. |

*Retention policies are the only thing that keeps storage flat. Nothing prunes a feed on its own.*

---

## A feed is a gate, not a folder

It decides what your teams publish and pull.

Start project scoped, turn on upstream sources instead of listing public registries in config files, and set retention policies before the first package lands.
