# Browser and extension management

Firefox and its extensions are managed declaratively from version-controlled configuration. That means the approved browser setup is defined as code instead of being installed and changed manually in the browser UI. In practice, this makes the installed state predictable, reproducible, and easy to inspect.

Extensions are pinned to exact released artifacts and verified by cryptographic hash at install time. Browser extensions are privileged code, so the approved extension set is explicitly allowlisted and pinned instead of being installed interactively and updated silently in the browser. This reduces silent drift, prevents background changes from altering the installed artifact unexpectedly, and makes every extension change explicit in configuration review.

From a security and IT-governance perspective, this improves software inventory and change control. The goal is not to bypass browser controls, but to replace ad-hoc local state with an auditable, reviewable, repeatable configuration.

## Additional notes

### What this improves

- explicit allowlist of installed browser extensions
- exact version pinning instead of implicit "latest"
- hash verification of downloaded extension artifacts
- reproducible rebuilds on new or reinstalled machines
- visible change history in git instead of hidden browser-local state
- reduced risk of silent extension drift across systems

### What this does not guarantee

- it does not prove an extension publisher is trustworthy
- it does not replace timely review and updates for security fixes
- it does not remove browser or extension vulnerabilities already present in a pinned version

### Why use Firefox wording here

Firefox is the term used here because the extension ecosystem, package format, and AMO distribution model are Firefox-based. The management approach treats browser extensions as controlled configuration rather than mutable local state.
