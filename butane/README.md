# Butane -> Ignition

Terraform reads compiled `.ign` files (see `terraform/main.tf`'s
`data.local_file` blocks), not the `.bu` YAML directly - Ignition needs
JSON, Butane is just the human-friendly source format.

Compile before every `terraform apply` that touches these configs:

```bash
# Install butane: https://coreos.github.io/butane/getting-started/
butane --pretty --strict controlplane.bu > controlplane.ign
butane --pretty --strict worker.bu > worker.ign
```

`--strict` makes Butane fail loudly on typos instead of silently
ignoring unknown fields - worth keeping on always.

Before compiling, replace the placeholder values in both `.bu` files:
- `REPLACE_WITH_YOUR_PUBLIC_SSH_KEY` in both files
- `REPLACE_WITH_TOKEN_FROM_CONTROLPLANE` in `worker.bu` (only needed
  once you're actually scaling up worker_count - see the comment
  block at the top of worker.bu for the full join-token workflow)

**Do not commit compiled `.ign` files or the worker token to git** -
add `*.ign` and any token files to `.gitignore`. The `.bu` source
files are fine to commit once the placeholders are templated out
(consider using Terraform's `templatefile()` on the `.bu` files
directly, feeding in a real SSH key variable, as a cleaner v2 than
manual find-and-replace).
