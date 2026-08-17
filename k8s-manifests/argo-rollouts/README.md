# Argo Rollouts

Installed via kubectl/Helm against the cluster, not via Terraform's
Helm provider - deliberately kept as a documented manual step for now,
since chaining Terraform -> Ignition -> k0s -> Helm provider adds a lot
of "did the cluster finish booting yet" race-condition risk for not
much benefit at portfolio scale. Worth mentioning this tradeoff
explicitly if asked in an interview - it's a real operational decision,
not laziness.

```bash
export KUBECONFIG=./controlplane-kubeconfig.yaml  # pulled from the controlplane node

kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

# CLI plugin for watching rollouts live - genuinely worth it for the demo recording
kubectl argo rollouts get rollout demo-app --watch
```

See `../demo-app/rollout.yaml` for the actual canary strategy
definition - that file, not this one, is where the interesting design
decisions live.
