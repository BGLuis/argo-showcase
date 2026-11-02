<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/header/graph.svg?title=Argo+Showcase&subtitle=Cloud+Native+CI%2FCD+%26+GitOps+with+Argo+Workflows+%2B+Argo+CD&align=left&font=geist-mono&mode=dark" />
    <img alt="Argo Showcase" src="https://shieldcn.dev/header/graph.svg?title=Argo+Showcase&subtitle=Cloud+Native+CI%2FCD+%26+GitOps+with+Argo+Workflows+%2B+Argo+CD&align=left&font=geist-mono&mode=light" />
  </picture>
</p>

<p align="center">
  <b>English</b> · <a href="README.pt-BR.md">Português (BR)</a>
</p>

<p align="center">
  <picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/github/stars/BGLuis/argo-showcase.svg?variant=secondary&size=sm&mode=dark" /><img alt="GitHub Stars" src="https://shieldcn.dev/github/stars/BGLuis/argo-showcase.svg?variant=secondary&size=sm&mode=light" /></picture>
  <picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/github/forks/BGLuis/argo-showcase.svg?variant=secondary&size=sm&mode=dark" /><img alt="GitHub Forks" src="https://shieldcn.dev/github/forks/BGLuis/argo-showcase.svg?variant=secondary&size=sm&mode=light" /></picture>
  <picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/github/watchers/BGLuis/argo-showcase.svg?variant=secondary&size=sm&mode=dark" /><img alt="Watchers" src="https://shieldcn.dev/github/watchers/BGLuis/argo-showcase.svg?variant=secondary&size=sm&mode=light" /></picture>
  <picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/github/contributors/BGLuis/argo-showcase.svg?theme=emerald&size=sm&mode=dark" /><img alt="Contributors" src="https://shieldcn.dev/github/contributors/BGLuis/argo-showcase.svg?theme=emerald&size=sm&mode=light" /></picture>
  <picture><source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/github/license/BGLuis/argo-showcase.svg?variant=ghost&size=sm&mode=dark" /><img alt="License" src="https://shieldcn.dev/github/license/BGLuis/argo-showcase.svg?variant=ghost&size=sm&mode=light" /></picture>
</p>

<p align="center">
  <img alt="Kubernetes" src="https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white" />
  <img alt="Argo Workflows" src="https://img.shields.io/badge/Argo_Workflows-EF7B42?style=flat&logo=argo&logoColor=white" />
  <img alt="Argo CD" src="https://img.shields.io/badge/Argo_CD-EF7B42?style=flat&logo=argo&logoColor=white" />
  <img alt="Kustomize" src="https://img.shields.io/badge/Kustomize-326CE5?style=flat&logo=kubernetes&logoColor=white" />
  <img alt="Bash" src="https://img.shields.io/badge/Bash-4EAA25?style=flat&logo=gnubash&logoColor=white" />
  <img alt="Linux" src="https://img.shields.io/badge/Platform-Linux-FCC624?style=flat&logo=linux&logoColor=black" />
</p>

---

# 📖 About

**Argo Showcase** is a modular, production-ready, hands-on demonstration repository showcasing the CNCF Graduated **Argo** ecosystem on Kubernetes. It bridges the complete cloud-native delivery lifecycle:

1. **Argo Workflows:** Container-native workflow engine orchestrating parallel steps, Directed Acyclic Graph (DAG) pipelines, artifact management, dynamic loops, conditional gates, and CI/CD automation.
2. **Argo CD:** Declarative GitOps continuous delivery controller automating drift detection, multi-environment synchronization, App of Apps topologies, and ApplicationSet generation.

Designed for both developers learning Kubernetes and platform engineers architecting enterprise deployment pipelines, this repository provides 1-command local cluster automation, interactive CLI demonstrations, and structured Kustomize overlays.

---

# 🏗️ Architecture & GitOps Flow

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                 CONTINUOUS INTEGRATION                                 │
│                                   (Argo Workflows)                                     │
│                                                                                        │
│   Developer Push ➔ [ 01-hello-world ]                                                  │
│                  ➔ [ 02-sequential-parallel-steps ]                                    │
│                  ➔ [ 03-dag-pipeline ] ─────┐                                          │
│                  ➔ [ 04-artifacts-params ]  ├──➔ [ 06-ci-cd-pipeline ]                │
│                  ➔ [ 05-loops-conditionals ]│     • Lint & Test                        │
│                  ➔ [ 07-templates ] ────────┘     • OCI Container Build                │
│                                                   • Trivy Vulnerability Scan           │
│                                                   • Update GitOps Commit Tag           │
└──────────────────────────────────────────┬─────────────────────────────────────────────┘
                                           │
                                     Git Commit Tag
                                           │
┌──────────────────────────────────────────▼─────────────────────────────────────────────┐
│                                 CONTINUOUS DELIVERY                                    │
│                                      (Argo CD)                                         │
│                                                                                        │
│      GitOps Repository (argocd/sample-app/overlays/{dev,prod})                         │
│                           │                                                            │
│                           ▼                                                            │
│        [ Argo CD Controller & Reconciliation Loop ]                                    │
│             │                               │                                          │
│    ├── 01-basic-app              ├── 02-app-of-apps          ├── 03-applicationset    │
│    │   Single Env Application    │   Root App managing       │   Matrix / List        │
│    │                             │   Child Applications      │   Multi-Env Generator  │
│    ▼                             ▼                           ▼                         │
│  Kubernetes Pods              Namespace: app-frontend      Namespaces: dev & prod      │
│  (dev-sample-app)             Namespace: app-backend       (sample-app-dev / prod)     │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

# ⚖️ Comparative Matrix

### Argo Workflows vs Traditional CI & Workflow Engines

| Feature / Capability | Argo Workflows | Jenkins | GitHub Actions / GitLab CI | Tekton Pipelines |
| :--- | :---: | :---: | :---: | :---: |
| **Execution Primitive** | Native Kubernetes Pods | VM / Daemon Worker Agents | Shared Runners / VM Agents | Kubernetes Pods (CRDs) |
| **Configuration Model** | Declarative CRD (`Workflow`) | Groovy DSL (Jenkinsfile) | Proprietary YAML | Kubernetes CRD (`Pipeline`) |
| **DAG Graph Modeling** | **Native (`dag.tasks`)** | Complex plugin scripting | Limited `needs:` syntax | Supported |
| **Artifact Repository** | S3 / GCS / MinIO built-in | Master node filesystem | Ephemeral Cache API | Workspace PVCs |
| **UI Pipeline Visualizer** | **Built-in Realtime DAG UI** | Blue Ocean (Legacy) | Web Console UI | Tekton Dashboard (Add-on) |
| **Multi-Tenancy & RBAC** | Kubernetes Namespace RBAC | Internal Jenkins ACLs | Organization / Repo Roles | Kubernetes Namespace RBAC |

### Argo CD vs Other Continuous Delivery Approaches

| Feature / Capability | Argo CD | Flux CD v2 | Helm CLI / Bash Scripts | Spinnaker |
| :--- | :---: | :---: | :---: | :---: |
| **GitOps Principle** | **Declarative Pull Model** | Declarative Pull Model | Imperative Push Model | Imperative / Event-Driven |
| **Web Dashboard UI** | **Rich Full-Featured GUI** | CLI Only (Weave GitOps add-on)| None | Complex Enterprise UI |
| **Drift Detection & Heal**| **Automatic & Real-time** | Automatic & Real-time | None (manual run required) | Polling / Canary gates |
| **Multi-Cluster Support** | Central Hub Controller | Multi-operator instances | Manual kubeconfig context | Native Multi-Cloud |
| **Multi-App Orchestration**| **App-of-Apps & ApplicationSet**| Kustomization dependencies | Custom Bash scripts | Pipelines & Stages |

---

# 💻 Getting Started

### Prerequisites

- [Docker Engine](https://docs.docker.com/engine/install/) >= 24.0.0
- [kubectl](https://kubernetes.io/docs/tasks/tools/) >= 1.28.0
- Local cluster engine: [k3d](https://k3d.io/) (recommended for speed) or [kind](https://kind.sigs.k8s.io/)

---

### Option 1: Automated Local Setup in 1 Command (Recommended)

Run the automated bootstrap script. It detects `k3d` or `kind`, provisions a local Kubernetes cluster with mapped Web UI ports, installs Argo CD and Argo Workflows with embedded artifact storage, and configures authentication:

```bash
bash scripts/setup-local.sh
```

**Access Dashboards:**

| Service | Local URL | Authentication / Credentials |
| :--- | :--- | :--- |
| **Argo CD UI** | [https://localhost:8080](https://localhost:8080) | Username: `admin`<br>Password: Printed by `setup-local.sh` or via CLI command below |
| **Argo Workflows UI** | [https://localhost:2746](https://localhost:2746) | Server authentication mode enabled (no token needed for local demo) |

> **Retrieve Argo CD Admin Password manually:**
> ```bash
> kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
> ```

---

### Option 2: Manual Installation on an Existing Cluster

If you already have a Kubernetes cluster (Minikube, K3s, EKS, GKE, AKS):

1. **Install Argo CD:**
   ```bash
   kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
   kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

2. **Install Argo Workflows:**
   ```bash
   kubectl create namespace argo --dry-run=client -o yaml | kubectl apply -f -
   kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v3.5.5/quick-start-minimal.yaml
   kubectl -n argo set image deployment/minio main=cgr.dev/chainguard/minio:latest
   ```

3. **Start Port Forwarding:**
   ```bash
   # Argo CD
   kubectl -n argocd port-forward svc/argocd-server 8080:443 &

   # Argo Workflows
   kubectl -n argo port-forward svc/argo-server 2746:2746 &
   ```

---

# 🎮 Interactive Demonstration

An interactive CLI demonstration script is provided to explore every workflow and GitOps pattern with colored explanations:

```bash
# Launch interactive menu
bash scripts/demo.sh

# Or run non-interactive automated tour
bash scripts/demo.sh --auto
```

---

# 🐙 Argo Workflows Showcase

All workflow manifests live under `workflows/` and use lightweight images (`alpine:3.19`) for instant local execution:

### 1. `01-hello-world` — Single Container Primitive
- **Path:** [`workflows/01-hello-world/workflow.yaml`](workflows/01-hello-world/workflow.yaml)
- **Concept:** Demonstrates the core `Workflow` CRD, dynamic pod naming via `generateName`, and basic container execution.
- **Run:**
  ```bash
  kubectl create -n argo -f workflows/01-hello-world/workflow.yaml
  ```

### 2. `02-sequential-parallel-steps` — Step Matrix Execution
- **Path:** [`workflows/02-sequential-parallel-steps/workflow.yaml`](workflows/02-sequential-parallel-steps/workflow.yaml)
- **Concept:** Demonstrates sequential vs parallel phases using 2D list step definitions. Outer lists execute in strict sequence; inner lists run concurrently.
- **Run:**
  ```bash
  kubectl create -n argo -f workflows/02-sequential-parallel-steps/workflow.yaml
  ```

### 3. `03-dag-pipeline` — Directed Acyclic Graph (Diamond Pattern)
- **Path:** [`workflows/03-dag-pipeline/workflow.yaml`](workflows/03-dag-pipeline/workflow.yaml)
- **Concept:** Models tasks with explicit dependency constraints (`dependencies: [A, B]`). Unlocks maximum task parallelism while ensuring fan-out and fan-in convergence.
- **Run:**
  ```bash
  kubectl create -n argo -f workflows/03-dag-pipeline/workflow.yaml
  ```

### 4. `04-artifacts-and-parameters` — Inter-Pod Data Passing
- **Path:** [`workflows/04-artifacts-and-parameters/workflow.yaml`](workflows/04-artifacts-and-parameters/workflow.yaml)
- **Concept:** Shows how ephemeral pods share state. Demonstrates output parameter capture (`valueFrom.path`) and tar artifact storage in MinIO mounted into downstream consumer pods.
- **Run:**
  ```bash
  kubectl create -n argo -f workflows/04-artifacts-and-parameters/workflow.yaml
  ```

### 5. `05-loops-and-conditionals` — Dynamic Flow Control
- **Path:** [`workflows/05-loops-and-conditionals/workflow.yaml`](workflows/05-loops-and-conditionals/workflow.yaml)
- **Concept:** Dynamic matrix loops using `withItems` across microservices and conditional execution gates using `when: "{{steps.gate.outputs.result}} == PROMOTE"`.
- **Run:**
  ```bash
  kubectl create -n argo -f workflows/05-loops-and-conditionals/workflow.yaml
  ```

### 6. `06-ci-cd-pipeline` — Production-Grade CI Pipeline
- **Path:** [`workflows/06-ci-cd-pipeline/workflow.yaml`](workflows/06-ci-cd-pipeline/workflow.yaml)
- **Concept:** End-to-end automation pipeline: Git checkout, linting, unit tests with coverage threshold, container image packaging, vulnerability scanning, and GitOps commit trigger.
- **Run:**
  ```bash
  kubectl create -n argo -f workflows/06-ci-cd-pipeline/workflow.yaml
  ```

### 7. `07-templates` — Reusable WorkflowTemplate
- **Path:** [`workflows/07-templates/workflow-template.yaml`](workflows/07-templates/workflow-template.yaml) & [`workflows/07-templates/run-template.yaml`](workflows/07-templates/run-template.yaml)
- **Concept:** DRY (Don't Repeat Yourself) architecture. Installs a cluster-scoped `WorkflowTemplate` and executes workflows that invoke it via `templateRef`.
- **Run:**
  ```bash
  kubectl apply -n argo -f workflows/07-templates/workflow-template.yaml
  kubectl create -n argo -f workflows/07-templates/run-template.yaml
  ```

---

# 🎯 Argo CD Showcase Patterns

Argo CD manifests live under `argocd/` and manage a structured Kustomize sample application:

### Sample Application Structure (`argocd/sample-app/`)
- **`base/`**: Standard unprivileged NGINX web deployment and ClusterIP service.
- **`overlays/dev/`**: 1 replica, `dev-` name prefix, `ENVIRONMENT=development` configuration.
- **`overlays/prod/`**: 3 replicas, `prod-` name prefix, `ENVIRONMENT=production` configuration.

Verify Kustomize output locally:
```bash
kubectl kustomize argocd/sample-app/overlays/dev
kubectl kustomize argocd/sample-app/overlays/prod
```

### GitOps Patterns:

#### 1. Basic Application (`01-basic-app`)
- **Path:** [`argocd/apps/01-basic-app/application.yaml`](argocd/apps/01-basic-app/application.yaml)
- **Concept:** Single declarative `Application` CRD with automated self-healing and namespace creation targeting `dev`.
- **Apply:**
  ```bash
  kubectl apply -f argocd/apps/01-basic-app/application.yaml
  ```

#### 2. App of Apps Pattern (`02-app-of-apps`)
- **Path:** [`argocd/apps/02-app-of-apps/root-application.yaml`](argocd/apps/02-app-of-apps/root-application.yaml)
- **Concept:** A **Root Application** monitoring a directory containing child `Application` manifests (`templates/app-frontend.yaml`, `templates/app-backend.yaml`). Teams add new microservices simply by committing a file to Git.
- **Apply:**
  ```bash
  kubectl apply -f argocd/apps/02-app-of-apps/root-application.yaml
  ```

#### 3. ApplicationSet Multi-Environment Pattern (`03-applicationset`)
- **Path:** [`argocd/apps/03-applicationset/applicationset-environments.yaml`](argocd/apps/03-applicationset/applicationset-environments.yaml)
- **Concept:** Generates dynamic `Application` resources across environments (`dev` and `prod`) using a list generator. Eliminates repetitive manifest duplication across clusters and tiers.
- **Apply:**
  ```bash
  kubectl apply -f argocd/apps/03-applicationset/applicationset-environments.yaml
  ```

---

# 🛠️ CLI Cheat Sheet

### Argo Workflows CLI (`argo`)

```bash
# Submit a workflow and follow live logs in terminal
argo submit -n argo --watch workflows/03-dag-pipeline/workflow.yaml

# List active and completed workflows
argo list -n argo

# Inspect status of a specific workflow
argo get -n argo <workflow-name>

# Stream logs of a running workflow
argo logs -n argo -f <workflow-name>

# Retry or resubmit a workflow
argo retry -n argo <workflow-name>
argo resubmit -n argo <workflow-name>
```

### Argo CD CLI (`argocd`)

```bash
# Log in to Argo CD API server
argocd login localhost:8080 --insecure --username admin

# List managed applications
argocd app list

# Inspect detailed sync and health status
argocd app get sample-app-dev

# Trigger manual synchronization
argocd app sync sample-app-dev

# View application logs
argocd app logs sample-app-dev
```

---

# 🧹 Teardown & Cleanup

To stop port forwards, delete the local cluster, and remove all resources created by this showcase:

```bash
bash scripts/teardown.sh
```

---

# 🤝 Contributors

<a href="https://github.com/BGLuis/argo-showcase/graphs/contributors">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/contributors/BGLuis/argo-showcase.svg?title=false&preset=transparent&border=false&mode=dark" />
    <img alt="Contributors" src="https://shieldcn.dev/contributors/BGLuis/argo-showcase.svg?title=false&preset=transparent&border=false&mode=light" />
  </picture>
</a>

---

# 📄 License

Distributed under the [MIT](LICENSE) license.
