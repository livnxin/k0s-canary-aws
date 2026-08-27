Goal of this project

This project is intended to be an MLOps project hosted in K8S as microservice

Eventual goal is 
- multi cloud multi cluster ML prediction service
- A/B testing along with canary deployment
- Security Hardening
- Observability

Roadmap

Stage 1 

- Deploy a single k8s cluster on AWS
- A/B testing of two models
- storage of prediction result and metadata in S3 as data lake
- Basic Security with Layer 4 Security Group to comply with the principle of least privilege. Only open ports when necessary and only to the right connection

Stage 2
- Add frontend
- Add another cluster and form cluster mesh
- Add observability

Stage 3
- Security
- Observability
- ML analysis of telemetry and security data

Stage 4 
- Active IPS
- Security Hardening

Architectural Decision

- Why cillium? layer 7 aware network policy, cluster mesh, integration with Hubble, eBPF networking that is better than Iptables

- Why talos? Immutable linux distro designed for Kubernetes