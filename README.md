# The Redemption — Cloud Engineer Assessment

Reference architecture and Infrastructure-as-Code for **"The Redemption"**, a
business-critical microservice on AWS EKS handling global hotel loyalty-point
deductions. Designed for zero-downtime operation under 10× flash-sale spikes,
with an active-standby disaster-recovery posture across two regions.

- **Primary:** Thailand — Bangkok (`ap-southeast-7`)
- **Standby:** Singapore (`ap-southeast-1`)

Deliverables: functional Terraform + Kubernetes manifests, an architecture
diagram (`docs/architecture.drawio`, two pages), and a design document
(`docs/DESIGN.txt` — export to PDF for submission).

---

## Repository layout

```
.
├── README.md
├── docs/
│   ├── THE-REDEMPTION.pdf  # design document PDF file — answers A–E + DR
│   ├── THE-REDEMPTION.docx # design document word file — answers A–E + DR
│   ├── architecture.md     # Mermaid diagrams + failure-mode tables
│   └── architecture.drawio # editable 2-page diagram (full arch + data tier)
├── terraform/
│   ├── versions.tf providers.tf locals.tf variables.tf outputs.tf
│   ├── kms-th.tf  kms-sg.tf
│   ├── vpc-th.tf  vpc-sg.tf
│   ├── eks-th.tf  eks-sg.tf
│   ├── iam-th.tf  iam-sg.tf        # Pod Identity role + controller IRSA roles
│   ├── secrets-th.tf               # Secrets Manager (replicated to SG)
│   ├── rds-th.tf  rds-sg.tf
│   ├── docdb-th.tf docdb-sg.tf
│   ├── redis-th.tf redis-sg.tf
│   ├── s3-th.tf   s3-sg.tf          # buckets + CRR + Multi-Region Access Point
│   ├── kafka-th.tf kafka-sg.tf
│   ├── ecr.tf  waf-th.tf waf-sg.tf  security-th.tf security-sg.tf
│   ├── observability.tf  route53.tf
│   ├── environments/
│   │   ├── prod-th.tfvars   prod-sg.tfvars
│   │   ├── staging-th.tfvars staging-sg.tfvars
│   │   └── dev-th.tfvars    dev-sg.tfvars
│   └── modules/
│       ├── kms/ vpc/ eks/ irsa/ secrets/
│       ├── rds/ docdb/ redis/ s3/ kafka/
│       └── waf/ ecr/ observability/
└── kubernetes/
    ├── base/        # namespace, SA (Pod Identity), deployment, svc, ingress, PDB
    ├── autoscaling/ # HPA v2, Karpenter NodePool (TH) + DR NodePool (SG)
    ├── policy/      # default-deny NetworkPolicy, External Secrets
    └── monitoring/  # ServiceMonitor + PrometheusRule SLO alerts
```

Each Terraform module is **single-region** and split by purpose (no catch-all
`main.tf`). Each region instantiates a module through its own root file
(`eks-th.tf` / `eks-sg.tf`, …). Cross-region replication (RDS replica, S3 CRR,
DocumentDB global cluster) is wired at the root where both providers are visible.

---

## Component highlights

| Area | Decision | Why |
|---|---|---|
| **Compute** | EKS 1.30 + system NG + **Karpenter** | 30–60 s node provisioning vs 3–5 min; Spot bin-packing |
| **Scaling** | HPA v2 on **RPS-per-pod** + CPU net | CPU lags request bursts; aggressive up, slow down |
| **Identity** | **Pod Identity** for the app, **IRSA** for controllers, **EKS Access Entries** for humans, **SSM** for node break-glass | no static keys, no aws-auth ConfigMap, no SSH/bastion |
| **Encryption** | dedicated **KMS** module — one CMK per domain; **Secrets Manager** + External Secrets | customer-managed keys everywhere, scoped + rotated |
| **Data** | RDS PostgreSQL, DocumentDB, ElastiCache, S3, MSK — all managed | small team operates the product, not stateful clusters |
| **Security** | WAF + rate-limit, default-deny NetworkPolicy, PSS restricted, IMDSv2 hop-1, GuardDuty + Security Hub | defense in depth, least privilege |
| **DR** | active-standby, per-service Global DNS, RDS replica, DocumentDB global cluster, S3 CRR+MRAP, cold Redis/Kafka | RTO ≤ 30 min, RPO ≤ 1 min |

Full reasoning, trade-offs, cost, and team plan: **`docs/DESIGN.txt`**.

---

## Deploying

```bash
cd terraform
terraform init

# Two var-files per environment — one per region. The -th file also carries
# the shared globals (project, dns, principals).
terraform apply \
  -var-file=environments/prod-th.tfvars \
  -var-file=environments/prod-sg.tfvars
```

Each `*.tfvars` is sectioned per module (`vpc_*`, `eks_*`, `rds_*`, …). `dev`
sets `enable_dr=false` so the Singapore stack is skipped (the `*_sg` variables
are still required by Terraform, hence `dev-sg.tfvars` exists with cheap values).

**Two-step for Route 53 failover:** ALB DNS names only exist after the AWS Load
Balancer Controller provisions them from the Ingress. First apply with the `alb`
variable empty (records skipped), apply the Kubernetes manifests, read the ALB
DNS back, then re-apply with `alb = { th_dns/th_zone_id/sg_dns/sg_zone_id }`
populated.

### Cluster bootstrap + application

```bash
aws eks update-kubeconfig --name redemption-prod-th --region ap-southeast-7
# helm: Karpenter, AWS Load Balancer Controller, External Secrets, ArgoCD,
#       Argo Rollouts, kube-prometheus-stack, OTel Collector, Fluent Bit
kubectl apply -f kubernetes/base/
kubectl apply -f kubernetes/policy/ -f kubernetes/autoscaling/ -f kubernetes/monitoring/
```

Replace `ACCOUNT_ID` / cert / image-tag placeholders with `terraform output`
values (in production these are templated by ArgoCD/Kustomize overlays).

---

## CI

`.github/workflows/ci.yml`: `terraform fmt -check`, `validate`, `tflint`,
`checkov`, `kubeconform`, `trivy config`.

---

## Notes for the reviewer

- Terraform is **functional but not blind-applyable**: it expects the bootstrap
  S3/DynamoDB backend (in `versions.tf`) and per-region tfvars. Structured for
  code review.
- Placeholders (`ACCOUNT_ID`, ACM/cert ARNs, image tags) are intentionally not
  fabricated.
- No CLI binary was available in the authoring environment, so `terraform
  validate` was not run here — review accordingly.
- Design rationale and the assessment answers are in `docs/DESIGN.txt`.
