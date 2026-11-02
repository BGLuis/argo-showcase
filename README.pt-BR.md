<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/header/graph.svg?title=Argo+Showcase&subtitle=CI%2FCD+Cloud+Native+%26+GitOps+com+Argo+Workflows+%2B+Argo+CD&align=left&font=geist-mono&mode=dark" />
    <img alt="Argo Showcase" src="https://shieldcn.dev/header/graph.svg?title=Argo+Showcase&subtitle=CI%2FCD+Cloud+Native+%26+GitOps+com+Argo+Workflows+%2B+Argo+CD&align=left&font=geist-mono&mode=light" />
  </picture>
</p>

<p align="center">
  <a href="README.md">English</a> · <b>Português (BR)</b>
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

# 📖 Sobre o Projeto

O **Argo Showcase** é um projeto prático, modular e didático focado na demonstração completa do ecossistema **Argo** (graduado pela CNCF) no Kubernetes. O repositório integra e exemplifica todo o ciclo de vida moderno de entrega contínua:

1. **Argo Workflows:** Motor nativo de Kubernetes para orquestração de pipelines e processamento em lote (CI/Automação), cobrindo passos paralelos, grafos acíclicos dirigidos (DAG), compartilhamento de artefatos, laços dinâmicos, verificações condicionais e esteiras de build/teste conteinerizadas.
2. **Argo CD:** Controlador declarativo de Continuous Delivery (CD) baseado nos princípios de **GitOps**, realizando reconciliação contínua de desvios (*drift detection*), sincronização automatizada, topologia *App of Apps* e provisionamento dinâmico multi-ambiente com *ApplicationSet*.

Seja para desenvolvedores que estão iniciando no ecossistema Kubernetes ou para engenheiros de plataforma arquitetando esteiras corporativas resilientes, este repositório oferece desde automação local em um comando até manifests Kustomize estruturados e scripts interativos de demonstração.

---

# 🏗️ Arquitetura e Fluxo GitOps

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                              INTEGRAÇÃO CONTÍNUA (CI)                                  │
│                                  (Argo Workflows)                                      │
│                                                                                        │
│   Push do Desenvolvedor ➔ [ 01-hello-world ]                                           │
│                         ➔ [ 02-sequential-parallel-steps ]                             │
│                         ➔ [ 03-dag-pipeline ] ─────┐                                    │
│                         ➔ [ 04-artifacts-params ]  ├──➔ [ 06-ci-cd-pipeline ]          │
│                         ➔ [ 05-loops-conditionals ]│     • Lint & Testes Unitários     │
│                         ➔ [ 07-templates ] ────────┘     • Build de Imagem OCI         │
│                                                          • Varredura de CVEs (Trivy)   │
│                                                          • Atualização da Tag GitOps   │
└──────────────────────────────────────────┬─────────────────────────────────────────────┘
                                           │
                                Commit da Nova Tag no Git
                                           │
┌──────────────────────────────────────────▼─────────────────────────────────────────────┐
│                                 ENTREGA CONTÍNUA (CD)                                  │
│                                       (Argo CD)                                        │
│                                                                                        │
│      Repositório GitOps (argocd/sample-app/overlays/{dev,prod})                        │
│                           │                                                            │
│                           ▼                                                            │
│       [ Argo CD Controller & Ciclo de Reconciliação ]                                  │
│             │                               │                                          │
│    ├── 01-basic-app              ├── 02-app-of-apps          ├── 03-applicationset    │
│    │   Aplicação Única           │   Aplicação Raiz          │   Gerador em Matriz     │
│    │                             │   gerenciando filhas      │   Multi-Ambiente        │
│    ▼                             ▼                           ▼                         │
│  Pods no Kubernetes           Namespace: app-frontend      Namespaces: dev & prod      │
│  (dev-sample-app)             Namespace: app-backend       (sample-app-dev / prod)     │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

---

# ⚖️ Matriz Comparativa

### Argo Workflows vs Ferramentas Tradicionais de CI / Pipelines

| Recurso / Capacidade | Argo Workflows | Jenkins | GitHub Actions / GitLab CI | Tekton Pipelines |
| :--- | :---: | :---: | :---: | :---: |
| **Primitiva de Execução** | Pods Nativos do Kubernetes | Agentes em VMs / Daemons | Runners Compartilhados / VMs | Pods Nativos (CRDs) |
| **Modelo de Configuração** | CRD Declarativo (`Workflow`) | Groovy DSL (Jenkinsfile) | YAML Proprietário | CRD Declarativo (`Pipeline`) |
| **Modelagem de Grafos (DAG)** | **Nativo de Primeira Classe** | Scripts complexos via plugins | Sintaxe simplificada (`needs:`) | Suportado |
| **Repositório de Artefatos** | MinIO / S3 / GCS embutido | Filesystem do nó mestre | API de Cache temporária | PVCs de Workspace |
| **Interface Visual de DAG** | **Dashboard com Grafo em Tempo Real** | Blue Ocean (Descontinuado) | Interface Web central | Tekton Dashboard (Adicional) |
| **Segurança e Multi-Tenancy** | RBAC nativo de Namespaces | ACLs internas do Jenkins | Papéis de Organização / Repo | RBAC nativo de Namespaces |

### Argo CD vs Outras Abordagens de Continuous Delivery

| Recurso / Capacidade | Argo CD | Flux CD v2 | Scripts com Helm CLI / Bash | Spinnaker |
| :--- | :---: | :---: | :---: | :---: |
| **Paradigma GitOps** | **Modelo Pull Declarativo** | Modelo Pull Declarativo | Modelo Push Imperativo | Imperativo / Baseado em Eventos |
| **Interface Gráfica (Web UI)**| **Dashboard Completo Integrado** | Apenas CLI (ou UI de terceiros)| Inexistente | Interface Complexa |
| **Detecção de Desvios (Drift)**| **Automática e Contínua** | Automática e Contínua | Nenhuma (requer re-execução) | Polling / Gates de Canary |
| **Suporte Multi-Cluster** | Controlador Central Hub | Múltiplos operadores locais | Contextos manuais de kubeconfig | Multi-Cloud Nativo |
| **Orquestração Multi-App** | **App-of-Apps & ApplicationSet** | Dependências de Kustomization | Scripts Bash customizados | Pipelines e Estágios |

---

# 💻 Primeiros Passos

### Pré-requisitos

- [Docker Engine](https://docs.docker.com/engine/install/) >= 24.0.0
- [kubectl](https://kubernetes.io/docs/tasks/tools/) >= 1.28.0
- Gerenciador de cluster local: [k3d](https://k3d.io/) (recomendado por velocidade) ou [kind](https://kind.sigs.k8s.io/)

---

### Opção 1: Setup Local Automático em 1 Comando (Recomendado)

O script de bootstrap detecta automaticamente `k3d` ou `kind`, provisiona o cluster local mapeando as portas de rede, instala o Argo CD e o Argo Workflows com MinIO integrado e configura autenticação facilitada para estudos:

```bash
bash scripts/setup-local.sh
```

**Painéis de Controle Disponíveis:**

| Serviço | URL Local | Autenticação / Credenciais |
| :--- | :--- | :--- |
| **Argo CD UI** | [https://localhost:8080](https://localhost:8080) | Usuário: `admin`<br>Senha: Gerada pelo `setup-local.sh` ou obtida pelo comando abaixo |
| **Argo Workflows UI** | [https://localhost:2746](https://localhost:2746) | Modo de autenticação via servidor habilitado (acesso direto local) |

> **Comando manual para obter a senha de administrador do Argo CD:**
> ```bash
> kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
> ```

---

### Opção 2: Instalação Manual em Cluster Existente

Se você já possui um cluster Kubernetes ativo (Minikube, K3s, EKS, GKE, AKS):

1. **Instalar o Argo CD:**
   ```bash
   kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

2. **Instalar o Argo Workflows:**
   ```bash
   kubectl create namespace argo --dry-run=client -o yaml | kubectl apply -f -
   kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/download/v3.5.5/quick-start-minimal.yaml
   kubectl patch deployment argo-server -n argo --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/args", "value": ["server", "--auth-mode=server"]}]'
   ```

3. **Iniciar Redirecionamento de Portas (Port-Forward):**
   ```bash
   # Argo CD
   kubectl -n argocd port-forward svc/argocd-server 8080:443 &

   # Argo Workflows
   kubectl -n argo port-forward svc/argo-server 2746:2746 &
   ```

---

# 🎮 Demonstração Interativa

O repositório inclui um script interativo com menu colorido e explicações conceituais de cada recurso:

```bash
# Execução interativa via menu numérico
bash scripts/demo.sh

# Ou execução automatizada passo a passo
bash scripts/demo.sh --auto
```

---

# 🐙 Detalhamento dos Exemplos: Argo Workflows

Todos os manifests de workflows estão localizados em `workflows/` e utilizam imagens ultraleves (`alpine:3.19`):

### 1. `01-hello-world` — Primitiva Básica de Container Único
- **Arquivo:** [`workflows/01-hello-world/workflow.yaml`](workflows/01-hello-world/workflow.yaml)
- **Conceito:** Introdução ao CRD `Workflow`, geração automática de sufixo aleatório (`generateName`) e execução isolada em pod.
- **Executar:**
  ```bash
  kubectl create -n argo -f workflows/01-hello-world/workflow.yaml
  ```

### 2. `02-sequential-parallel-steps` — Matriz de Passos Sequenciais e Concorrentes
- **Arquivo:** [`workflows/02-sequential-parallel-steps/workflow.yaml`](workflows/02-sequential-parallel-steps/workflow.yaml)
- **Conceito:** Execução de listas aninhadas em YAML. A lista externa define a sequência temporal; a lista interna dispara pods simultâneos em paralelo.
- **Executar:**
  ```bash
  kubectl create -n argo -f workflows/02-sequential-parallel-steps/workflow.yaml
  ```

### 3. `03-dag-pipeline` — Grafo Acíclico Dirigido (Padrão Diamante)
- **Arquivo:** [`workflows/03-dag-pipeline/workflow.yaml`](workflows/03-dag-pipeline/workflow.yaml)
- **Conceito:** Declaração explícita de dependências entre tarefas (`dependencies: [checkout, lint]`), permitindo convergência de múltiplos ramos em nós de agregação.
- **Executar:**
  ```bash
  kubectl create -n argo -f workflows/03-dag-pipeline/workflow.yaml
  ```

### 4. `04-artifacts-and-parameters` — Troca de Dados Entre Pods Efêmeros
- **Arquivo:** [`workflows/04-artifacts-and-parameters/workflow.yaml`](workflows/04-artifacts-and-parameters/workflow.yaml)
- **Conceito:** Captura dinâmica de parâmetros via `valueFrom.path` e armazenamento de arquivos e artefatos em bucket MinIO/S3 para consumo no pod downstream.
- **Executar:**
  ```bash
  kubectl create -n argo -f workflows/04-artifacts-and-parameters/workflow.yaml
  ```

### 5. `05-loops-and-conditionals` — Controle de Fluxo Dinâmico
- **Arquivo:** [`workflows/05-loops-and-conditionals/workflow.yaml`](workflows/05-loops-and-conditionals/workflow.yaml)
- **Conceito:** Iterações em matriz através de `withItems` e desvios condicionais avaliados em tempo de execução com `when`.
- **Executar:**
  ```bash
  kubectl create -n argo -f workflows/05-loops-and-conditionals/workflow.yaml
  ```

### 6. `06-ci-cd-pipeline` — Esteira Completa de CI/CD para Produção
- **Arquivo:** [`workflows/06-ci-cd-pipeline/workflow.yaml`](workflows/06-ci-cd-pipeline/workflow.yaml)
- **Conceito:** Pipeline completo: checkout do código, linting, testes com limite mínimo de cobertura, build simulado de imagem OCI, varredura de vulnerabilidades com Trivy e notificação/commit GitOps.
- **Executar:**
  ```bash
  kubectl create -n argo -f workflows/06-ci-cd-pipeline/workflow.yaml
  ```

### 7. `07-templates` — Reaproveitamento Modular com WorkflowTemplate
- **Arquivos:** [`workflows/07-templates/workflow-template.yaml`](workflows/07-templates/workflow-template.yaml) e [`workflows/07-templates/run-template.yaml`](workflows/07-templates/run-template.yaml)
- **Conceito:** Padrão DRY. Define um `WorkflowTemplate` reutilizável em todo o cluster/namespace e permite que múltiplos workflows o invoquem via `templateRef`.
- **Executar:**
  ```bash
  kubectl apply -n argo -f workflows/07-templates/workflow-template.yaml
  kubectl create -n argo -f workflows/07-templates/run-template.yaml
  ```

---

# 🎯 Padrões do Argo CD e Aplicação de Exemplo

Os manifests do Argo CD estão organizados em `argocd/` e gerenciam uma aplicação web de exemplo baseada em Kustomize:

### Estrutura da Aplicação de Exemplo (`argocd/sample-app/`)
- **`base/`**: Deployment NGINX sem privilégios e Service ClusterIP padronizado.
- **`overlays/dev/`**: 1 réplica, prefixo de nome `dev-` e variável `ENVIRONMENT=development`.
- **`overlays/prod/`**: 3 réplicas, prefixo de nome `prod-` e variável `ENVIRONMENT=production`.

Validação local do Kustomize sem aplicar ao cluster:
```bash
kubectl kustomize argocd/sample-app/overlays/dev
kubectl kustomize argocd/sample-app/overlays/prod
```

### Padrões de Entrega Contínua:

#### 1. Aplicação Básica (`01-basic-app`)
- **Arquivo:** [`argocd/apps/01-basic-app/application.yaml`](argocd/apps/01-basic-app/application.yaml)
- **Conceito:** Manifest declarativo `Application` apontando para o Git, com autocura ativada (`selfHeal: true`) e criação automática de namespace.
- **Aplicar:**
  ```bash
  kubectl apply -f argocd/apps/01-basic-app/application.yaml
  ```

#### 2. Padrão App of Apps (`02-app-of-apps`)
- **Arquivo:** [`argocd/apps/02-app-of-apps/root-application.yaml`](argocd/apps/02-app-of-apps/root-application.yaml)
- **Conceito:** Uma **Root Application** que monitora uma pasta contendo manifests filhos (`templates/app-frontend.yaml`, `templates/app-backend.yaml`). Novos microsserviços são ativados com um simples commit no Git.
- **Aplicar:**
  ```bash
  kubectl apply -f argocd/apps/02-app-of-apps/root-application.yaml
  ```

#### 3. Padrão ApplicationSet Multi-Ambiente (`03-applicationset`)
- **Arquivo:** [`argocd/apps/03-applicationset/applicationset-environments.yaml`](argocd/apps/03-applicationset/applicationset-environments.yaml)
- **Conceito:** Geração dinâmica de instâncias de `Application` para múltiplos ambientes (`dev` e `prod`) através de geradores de lista, eliminando código duplicado.
- **Aplicar:**
  ```bash
  kubectl apply -f argocd/apps/03-applicationset/applicationset-environments.yaml
  ```

---

# 🛠️ Tabela Rápida de Comandos CLI

### CLI do Argo Workflows (`argo`)

```bash
# Submeter workflow e acompanhar logs em tempo real
argo submit -n argo --watch workflows/03-dag-pipeline/workflow.yaml

# Listar workflows ativos e finalizados
argo list -n argo

# Inspecionar detalhes de um workflow
argo get -n argo <nome-do-workflow>

# Exibir logs de um workflow
argo logs -n argo -f <nome-do-workflow>

# Tentar novamente ou reexecutar um workflow
argo retry -n argo <nome-do-workflow>
argo resubmit -n argo <nome-do-workflow>
```

### CLI do Argo CD (`argocd`)

```bash
# Autenticar no servidor do Argo CD
argocd login localhost:8080 --insecure --username admin

# Listar aplicações gerenciadas
argocd app list

# Exibir status de sincronização e saúde da aplicação
argocd app get sample-app-dev

# Disparar sincronização manual forçada
argocd app sync sample-app-dev

# Acompanhar logs dos pods da aplicação
argocd app logs sample-app-dev
```

---

# 🧹 Teardown e Limpeza de Recursos

Para encerrar processos em segundo plano, excluir o cluster local e liberar todas as portas e recursos:

```bash
bash scripts/teardown.sh
```

---

# 🤝 Contribuidores

<a href="https://github.com/BGLuis/argo-showcase/graphs/contributors">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://shieldcn.dev/contributors/BGLuis/argo-showcase.svg?title=false&preset=transparent&border=false&mode=dark" />
    <img alt="Contributors" src="https://shieldcn.dev/contributors/BGLuis/argo-showcase.svg?title=false&preset=transparent&border=false&mode=light" />
  </picture>
</a>

---

# 📄 Licença

Distribuído sob a licença [MIT](LICENSE).
