# Agent security on macOS

This document describes the current security model for AI coding agents on my macOS machines, why it exists, and how the pieces fit together.

## Goals

The setup is designed around these goals:

- keep the default agent workflow convenient enough to use every day
- reduce the blast radius of autonomous agent mistakes
- reduce exposure of host credentials, shell state, and personal files
- provide a stronger isolation mode for untrusted code and long-running sessions
- keep the setup declarative where practical
- make the security posture understandable and auditable later

This is not trying to create a perfect security boundary. It is trying to create a practical layered model that is much safer than running agents directly as the main user on the host.

## Threat model

The main risks being addressed are:

- agent executes destructive shell commands
- agent reads host credentials or sensitive files
- agent modifies shell startup or other persistence points
- malicious repositories or prompt injection try to steer the agent into dangerous actions
- supply-chain attacks in package installs or test/build scripts
- long autonomous sessions drift into unsafe territory
- untrusted code escapes a weak sandbox and reaches the host

The highest-value host assets include:

- SSH keys and agent access
- git forge credentials
- cloud credentials
- browser and keychain-adjacent material
- repo-local secrets and deployment config
- dotfiles and machine configuration

## Design overview

There are two execution tiers for Pi on macOS.

### Tier 1: default host workflow

Command:

```sh
pi
```

This is the everyday workflow.

`pi` is wrapped by `bin/pi` and always launches Pi through Hazmat:

```sh
hazmat exec pi-coding-agent
```

This keeps the default UX simple while adding host-side containment.

### Tier 4: high-isolation VM workflow

Command:

```sh
pi-vm
```

This runs Pi inside a Lima-managed Linux VM with no host mounts.

This is the stronger workflow for:

- untrusted repositories
- dependency installation
- build/test execution for unknown code
- high-autonomy sessions
- anything where a host escape would be especially costly

## Why Hazmat for the default path

Hazmat was chosen as the default macOS containment layer because it is:

- macOS-native
- agent-focused
- designed for autonomous coding agents
- stronger than simple shell wrappers or path-based tricks
- much more practical on macOS than Linux-first tools like Bubblewrap

Hazmat adds several important controls:

- separate macOS user for the agent
- seatbelt sandboxing
- pf-based network restrictions
- credential path denial
- rollback-oriented workflow via snapshots

This does not make the host perfectly safe. Hazmat itself documents important limits, especially around HTTPS egress and the fact that seatbelt is not a VM-grade boundary. But it is still a strong improvement over running agents directly as the main user.

## Why a VM path exists as well

Hazmat is strong for a host-native workflow, but it is still host-side containment.

A full VM provides a meaningfully stronger boundary:

- separate kernel
- hardware-backed virtualization boundary
- container escape is no longer enough to reach the host
- clean reset/destroy workflow

For higher-risk sessions, this stronger isolation is worth the extra friction.

## Current components

### 1. Standalone Pi flake

Pi is packaged in its own standalone flake:

- path: `~/Development/pi-coding-agent-flake`

Reasoning:

- package lifecycle is separated from dotfiles logic
- version/hash updates are isolated
- easier to reuse on multiple machines
- dotfiles only need to consume the package as an input

### 2. Standalone Hazmat flake

Hazmat is also packaged in its own standalone flake:

- path: `~/Development/hazmat-flake`

Reasoning:

- avoids Homebrew as the installation source
- keeps the agent-security tooling declarative through Nix
- matches the packaging model already used for Pi
- keeps upgrade logic independent from the main dotfiles repo

### 3. LLM module owns agent tooling

The relevant packages now live in `home/modules/llm.nix`.

That module installs:

- Pi
- Hazmat
- Lima
- other LLM/coding-agent tools already kept there

Reasoning:

- these tools are part of the agent/LLM workflow
- keeping them together makes intent clearer
- agent runtime and containment belong together conceptually

### 4. `bin/pi`

Wrapper script that always routes Pi through Hazmat.

Purpose:

- safe default
- no need to remember a separate command
- keeps muscle memory simple
- prevents accidental unsandboxed Pi usage

### 5. `bin/pi-vm`

Wrapper script for the Tier 4 workflow using Lima.

Purpose:

- explicit higher-isolation path
- easy lifecycle management
- avoids hand-running `limactl` for common actions
- keeps the stronger workflow accessible enough to actually use

## Lima VM design

### Configuration location

- `config/lima/pi-vm.yaml`
- `config/lima/README.md`

### Important properties

The VM config intentionally uses:

```yaml
mounts: []
```

This is critical.

Reasoning:

- no host home exposure
- no host repo exposure
- no accidental access to SSH keys, cloud config, browser data, or dotfiles
- preserves the value of the VM boundary

The intended model is:

- start the VM
- open a shell inside it
- clone the target repository inside the VM
- run Pi inside the VM
- review/export results separately

This is stricter than bind-mounting a host repo, but that strictness is the point of Tier 4.

### Network policy in the VM

The current VM provisioning installs an outbound firewall policy that reduces egress to:

- loopback
- established/related traffic
- DNS
- HTTPS

This is not a perfect exfiltration control.

Reasoning:

- Pi still needs network access for model APIs and normal software retrieval
- a deny-by-default plus narrow protocol allowlist is much better than unrestricted egress
- a domain/IP allowlist can be added later if needed, but the first step is cutting off obvious unnecessary protocols

### Why Linux guest instead of macOS guest

The current VM path uses Ubuntu via Lima rather than a macOS guest.

Reasoning:

- simpler and more mature for this use case
- easy noninteractive provisioning
- easier package installation for Pi runtime
- lower setup burden than a full macOS guest workflow
- good enough because the goal is stronger isolation, not macOS API parity inside the guest

Tradeoff:

- Darwin-specific workflows should stay on the Hazmat path
- the VM path is primarily for stronger isolation, not for all host-specific tasks

## When to use which path

### Use `pi` when

- working on trusted code
- doing normal repo inspection/editing
- you want the fastest, least disruptive workflow
- the task benefits from host-native environment access but should still be contained

### Use `pi-vm` when

- the repository is untrusted or only partially trusted
- you expect dependency installs, tests, or build scripts to run
- you want longer autonomous runs
- you want a stronger boundary than host-side containment
- the task can tolerate cloning the repo inside the VM

## Operational guidance

### Default assumption

The default safe habit should be:

- `pi` for normal work
- `pi-vm` for risky work

Never run Pi directly outside those wrappers.

### Repo handling in VM mode

For `pi-vm`, prefer:

- clone inside VM
- keep work inside VM
- push a branch from inside VM, or export a patch deliberately

Avoid:

- host mounts into the VM
- sharing host secrets into the VM
- forwarding broad credential sets without need

### Credential handling

`pi-vm` currently forwards a defined set of environment variables only for the current invocation.

This is better than ambient host state, but still a trust decision.

Design intent:

- make credential forwarding explicit
- avoid mounting host home/config
- keep forwarded secrets scoped to the runtime invocation rather than the whole machine state

This can be tightened later if needed.

## Design tradeoffs

### Why not only use Hazmat

Hazmat is good, but not strong enough for every case.

Reasons not to rely on it alone:

- still host-side containment
- not a separate kernel
- not a full VM boundary
- known limitations around HTTPS egress and some environment/process inheritance issues

### Why not only use VMs

VMs are stronger but not the only practical answer.

Reasons not to force all work into VMs:

- more friction
- slower startup and workflow iteration
- Darwin-specific host tasks become awkward
- if too inconvenient, it will not be used consistently

The two-tier model exists to balance usability and security.

### Why no host mounts in Tier 4

Because host mounts undo too much of the value.

Host mounts would reintroduce:

- host file exposure
- accidental credential bleed
- weaker conceptual boundary
- more confusing security semantics

Tier 4 is intentionally opinionated here.

## Future improvements

Possible next steps:

- stronger VM snapshot/reset workflow
- helper command to clone repos into the VM
- domain/IP allowlist instead of broad HTTPS allowance
- explicit profile split such as trusted vs hostile VM instances
- patch export helper from VM to host review flow
- better handling around API key injection for VM sessions
- clearer preflight checks for `hazmat init` and VM provisioning state

## Files involved

### Dotfiles repo

- `home/modules/llm.nix`
- `bin/pi`
- `bin/pi-vm`
- `config/lima/pi-vm.yaml`
- `config/lima/README.md`
- `flake.nix`
- `flake.lock`

### External flakes

- `~/Development/pi-coding-agent-flake`
- `~/Development/hazmat-flake`

## Summary

The current model is:

- **default:** Pi via Hazmat on host
- **high isolation:** Pi via Lima VM with no host mounts

This gives:

- a convenient contained default
- a stronger VM-backed path for riskier work
- separation of packaging concerns through standalone flakes
- security design that is understandable enough to extend later

It is not perfect, but it is intentionally layered, practical, and much safer than direct host execution.
