#!/usr/bin/env bash
# ==============================================================================
# scripts/demo.sh
# Interactive & Guided Demonstration: Argo Workflows + Argo CD Showcase
# ==============================================================================

set -eo pipefail

export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"

BOLD="\033[1m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
MAGENTA="\033[1;35m"
DIM="\033[2m"
RESET="\033[0m"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUTO_MODE=false

if [[ "${1:-}" == "--auto" ]]; then
    AUTO_MODE=true
fi

pause() {
    if [ "$AUTO_MODE" = false ]; then
        echo -e "\n${YELLOW}▶ Press [ENTER] to continue...${RESET}"
        read -r
    else
        echo ""
        sleep 2
    fi
}

header() {
    clear 2>/dev/null || true
    echo -e "${MAGENTA}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${MAGENTA}║              ARGO ECOSYSTEM SHOWCASE (Workflows + Argo CD)                 ║${RESET}"
    echo -e "${MAGENTA}║      Cloud Native Continuous Integration, Automation & GitOps Delivery      ║${RESET}"
    echo -e "${MAGENTA}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

has_cluster() {
    kubectl cluster-info &>/dev/null
}

run_workflow_demo() {
    local file="$1"
    local desc="$2"

    echo -e "${BLUE}--- Manifest File: ${file} ---${RESET}"
    cat "${REPO_ROOT}/${file}"
    echo ""
    echo -e "${BLUE}------------------------------------------------------------${RESET}"

    if has_cluster; then
        echo -e "\n${CYAN}Cluster connection detected!${RESET}"
        if [ "$AUTO_MODE" = true ]; then
            SUBMIT="y"
        else
            read -p "Do you want to submit this workflow to the 'argo' namespace now? (Y/n): " -r SUBMIT
        fi

        if [[ ! "$SUBMIT" =~ ^[Nn]$ ]]; then
            echo -e "${GREEN}Submitting workflow to Kubernetes cluster...${RESET}"
            if command -v argo &>/dev/null; then
                argo submit -n argo --watch "${REPO_ROOT}/${file}" || true
            else
                CREATED=$(kubectl create -n argo -f "${REPO_ROOT}/${file}" -o jsonpath="{.metadata.name}" 2>/dev/null || true)
                if [ -n "$CREATED" ]; then
                    echo -e "${GREEN}✔ Workflow submitted: ${CREATED}${RESET}"
                    sleep 2
                    echo -e "\n${BOLD}Workflow Resource Status:${RESET}"
                    kubectl get workflow -n argo "${CREATED}" 2>/dev/null || true
                    echo -e "\n${BOLD}Associated Pods:${RESET}"
                    kubectl get pods -n argo -l "workflows.argoproj.io/workflow=${CREATED}" 2>/dev/null || true
                    echo -e "\n${DIM}Follow in real-time on Web UI: https://localhost:2746${RESET}"
                else
                    kubectl apply -n argo -f "${REPO_ROOT}/${file}" || true
                fi
            fi
        fi
    else
        echo -e "${YELLOW}ℹ [Offline Mode] Cluster not connected.${RESET}"
        echo -e "To execute this in your cluster, run:"
        echo -e "  ${BOLD}kubectl create -n argo -f ${file}${RESET}"
        echo -e "Or with the Argo CLI:"
        echo -e "  ${BOLD}argo submit -n argo --watch ${file}${RESET}"
        echo -e "${DIM}(Run 'bash scripts/setup-local.sh' to start a local 1-command cluster)${RESET}"
    fi
}

step_overview() {
    header
    echo -e "${CYAN}${BOLD}[OVERVIEW] The Argo Project in Cloud Native Architecture${RESET}\n"
    echo -e "Modern Kubernetes-native software engineering divides CI and CD into specialized tools:"
    echo ""
    echo -e "  ${BOLD}1. Argo Workflows (Continuous Integration & Batch Processing):${RESET}"
    echo -e "     • Runs each step as an isolated, ephemeral Kubernetes Pod."
    echo -e "     • Replaces heavy legacy CI servers (like Jenkins) with declarative CRDs."
    echo -e "     • Native support for Directed Acyclic Graphs (DAG), parallel steps, artifacts, and loops."
    echo ""
    echo -e "  ${BOLD}2. Argo CD (Declarative Continuous Delivery & GitOps):${RESET}"
    echo -e "     • Implements Git as the single source of truth for desired cluster state."
    echo -e "     • Continuously detects drift between Git and live Kubernetes clusters."
    echo -e "     • Automated self-healing, progressive rollouts, and multi-cluster orchestration."
    echo ""
    echo -e "  ${BOLD}How they integrate together:${RESET}"
    echo -e "     Argo Workflows (Build, Test, Scan) ➔ Commits image tag to Git ➔ Argo CD syncs to Kubernetes."
    pause
}

step_01() {
    header
    echo -e "${CYAN}${BOLD}[DEMO 01] Hello World: Single Container Execution${RESET}\n"
    echo -e "The simplest Argo Workflow primitive. Demonstrates:"
    echo -e "  • ${BOLD}apiVersion: argoproj.io/v1alpha1${RESET} & ${BOLD}kind: Workflow${RESET}"
    echo -e "  • ${BOLD}generateName:${RESET} Kubernetes appends a random hash for each workflow execution."
    echo -e "  • ${BOLD}entrypoint:${RESET} specifies the root template to execute."
    echo ""
    run_workflow_demo "workflows/01-hello-world/workflow.yaml" "Hello World"
    pause
}

step_02() {
    header
    echo -e "${CYAN}${BOLD}[DEMO 02] Sequential & Parallel Steps Execution${RESET}\n"
    echo -e "Argo Workflows models parallel and sequential steps using a 2D matrix in YAML:"
    echo -e "  • Outer list items: execute ${BOLD}sequentially${RESET} (Phase 1 ➔ Phase 2 ➔ Phase 3)."
    echo -e "  • Inner list items: execute ${BOLD}concurrently in parallel${RESET} (Phase 2A, 2B, 2C run at once)."
    echo ""
    run_workflow_demo "workflows/02-sequential-parallel-steps/workflow.yaml" "Sequential & Parallel Steps"
    pause
}

step_03() {
    header
    echo -e "${CYAN}${BOLD}[DEMO 03] DAG Pipeline (Directed Acyclic Graph)${RESET}\n"
    echo -e "DAG allows modeling complex dependency graphs instead of rigid step sequences:"
    echo -e "  • Defines explicit dependencies via: ${BOLD}dependencies: [checkout-source]${RESET}"
    echo -e "  • Multiple branches join together in fan-in nodes: ${BOLD}dependencies: [A, B, C]${RESET}"
    echo -e "  • Unlocks maximum execution concurrency while respecting strict task prerequisites."
    echo ""
    run_workflow_demo "workflows/03-dag-pipeline/workflow.yaml" "DAG Pipeline"
    pause
}

step_04() {
    header
    echo -e "${CYAN}${BOLD}[DEMO 04] Artifacts & Parameters Passing${RESET}\n"
    echo -e "Containers are ephemeral; passing data between different pods is essential:"
    echo -e "  • ${BOLD}Parameters:${RESET} Lightweight string data captured via stdout or file (e.g. version hashes)."
    echo -e "  • ${BOLD}Artifacts:${RESET} Files, archives, or binaries saved to artifact storage (MinIO/S3)"
    echo -e "    and mounted automatically into downstream consumer pods."
    echo ""
    run_workflow_demo "workflows/04-artifacts-and-parameters/workflow.yaml" "Artifacts & Parameters"
    pause
}

step_05() {
    header
    echo -e "${CYAN}${BOLD}[DEMO 05] Loops & Conditionals${RESET}\n"
    echo -e "Dynamic pipeline behavior without writing boilerplate code:"
    echo -e "  • ${BOLD}withItems:${RESET} Matrix loop executing tasks over a list of items or objects."
    echo -e "  • ${BOLD}when:${RESET} Conditional gates (e.g. when '{{steps.gate.outputs.result}} == PROMOTE')."
    echo -e "  • Avoids unnecessary deployments and enables safe canary branching."
    echo ""
    run_workflow_demo "workflows/05-loops-and-conditionals/workflow.yaml" "Loops & Conditionals"
    pause
}

step_06() {
    header
    echo -e "${CYAN}${BOLD}[DEMO 06] Real-World CI/CD Pipeline${RESET}\n"
    echo -e "A production-grade pipeline bridging CI (Argo Workflows) and CD (Argo CD):"
    echo -e "  1. Git checkout & commit verification."
    echo -e "  2. Static linting, unit test coverage, and CVE audit."
    echo -e "  3. Multi-stage OCI container image build."
    echo -e "  4. Container vulnerability scanning."
    echo -e "  5. GitOps repository commit & Argo CD sync notification."
    echo ""
    run_workflow_demo "workflows/06-ci-cd-pipeline/workflow.yaml" "Real-World CI/CD"
    pause
}

step_07() {
    header
    echo -e "${CYAN}${BOLD}[DEMO 07] Reusable WorkflowTemplates${RESET}\n"
    echo -e "Promoting DRY (Don't Repeat Yourself) across enterprise engineering teams:"
    echo -e "  • ${BOLD}WorkflowTemplate:${RESET} Reusable template stored in Kubernetes cluster/namespace."
    echo -e "  • Workflows invoke it using ${BOLD}templateRef: { name: reusable-ci-templates, template: ... }${RESET}"
    echo -e "  • Eliminates duplicated pipeline definitions across hundreds of microservices."
    echo ""
    echo -e "${BLUE}--- Template Definition: workflows/07-templates/workflow-template.yaml ---${RESET}"
    cat "${REPO_ROOT}/workflows/07-templates/workflow-template.yaml"
    echo ""
    echo -e "${BLUE}--- Caller Workflow: workflows/07-templates/run-template.yaml ---${RESET}"
    cat "${REPO_ROOT}/workflows/07-templates/run-template.yaml"
    echo ""
    if has_cluster; then
        echo -e "${CYAN}Applying WorkflowTemplate to cluster...${RESET}"
        kubectl apply -n argo -f "${REPO_ROOT}/workflows/07-templates/workflow-template.yaml" || true
        echo -e "${GREEN}✔ WorkflowTemplate 'reusable-ci-templates' installed.${RESET}"
    fi
    run_workflow_demo "workflows/07-templates/run-template.yaml" "Run WorkflowTemplate"
    pause
}

step_08() {
    header
    echo -e "${CYAN}${BOLD}[ARGO CD 01] Basic Application & Kustomize Structure${RESET}\n"
    echo -e "Declarative GitOps application management:"
    echo -e "  • Source of truth: Git repository path ${BOLD}argocd/sample-app/overlays/dev${RESET}"
    echo -e "  • Target cluster: ${BOLD}https://kubernetes.default.svc${RESET} (namespace: sample-app-dev)"
    echo -e "  • Automated self-heal: reconciles live cluster drift automatically back to Git."
    echo ""
    echo -e "${BLUE}--- Kustomize Base Deployment: argocd/sample-app/base/deployment.yaml ---${RESET}"
    cat "${REPO_ROOT}/argocd/sample-app/base/deployment.yaml"
    echo ""
    echo -e "${BLUE}--- Argo CD Application: argocd/apps/01-basic-app/application.yaml ---${RESET}"
    cat "${REPO_ROOT}/argocd/apps/01-basic-app/application.yaml"
    echo ""
    if has_cluster; then
        echo -e "${CYAN}Cluster connection detected!${RESET}"
        if [ "$AUTO_MODE" = false ]; then
            read -p "Do you want to test deploy the sample-app directly via Kustomize? (y/N): " -r KUST_APPLY
            if [[ "$KUST_APPLY" =~ ^[Yy]$ ]]; then
                echo -e "${GREEN}Applying Kustomize overlay (dev) to cluster...${RESET}"
                kubectl create namespace sample-app-dev --dry-run=client -o yaml | kubectl apply -f -
                kubectl apply -k "${REPO_ROOT}/argocd/sample-app/overlays/dev" -n sample-app-dev
                echo -e "\n${BOLD}Live Pods in sample-app-dev:${RESET}"
                kubectl get pods,svc -n sample-app-dev
            fi

            read -p "Do you want to apply the Argo CD Application manifest now? (y/N): " -r APP_APPLY
            if [[ "$APP_APPLY" =~ ^[Yy]$ ]]; then
                echo -e "${GREEN}Applying Application to Argo CD...${RESET}"
                kubectl apply -f "${REPO_ROOT}/argocd/apps/01-basic-app/application.yaml" || true
                kubectl get application -n argocd sample-app-dev 2>/dev/null || true
            fi
        fi
    fi
    pause
}

step_09() {
    header
    echo -e "${CYAN}${BOLD}[ARGO CD 02] App of Apps Pattern${RESET}\n"
    echo -e "Managing large collections of applications declaratively:"
    echo -e "  • Instead of creating individual applications manually, deploy a ${BOLD}Root Application${RESET}."
    echo -e "  • The Root Application monitors a folder with child ${BOLD}Application${RESET} manifests."
    echo -e "  • Adding a new service is as simple as committing a new YAML file to Git!"
    echo ""
    echo -e "${BLUE}--- Root Application: argocd/apps/02-app-of-apps/root-application.yaml ---${RESET}"
    cat "${REPO_ROOT}/argocd/apps/02-app-of-apps/root-application.yaml"
    echo ""
    echo -e "${BLUE}--- Child App Example: argocd/apps/02-app-of-apps/templates/app-frontend.yaml ---${RESET}"
    cat "${REPO_ROOT}/argocd/apps/02-app-of-apps/templates/app-frontend.yaml"
    echo ""
    if has_cluster; then
        echo -e "${CYAN}Cluster connection detected!${RESET}"
        if [ "$AUTO_MODE" = false ]; then
            read -p "Do you want to apply the Root Application manifest to Argo CD? (y/N): " -r ROOT_APPLY
            if [[ "$ROOT_APPLY" =~ ^[Yy]$ ]]; then
                echo -e "${GREEN}Applying Root Application to Argo CD...${RESET}"
                kubectl apply -f "${REPO_ROOT}/argocd/apps/02-app-of-apps/root-application.yaml" || true
                kubectl get applications -n argocd 2>/dev/null || true
            fi
        fi
    fi
    pause
}

step_10() {
    header
    echo -e "${CYAN}${BOLD}[ARGO CD 03] ApplicationSet Multi-Environment Pattern${RESET}\n"
    echo -e "Next-generation GitOps automation:"
    echo -e "  • Uses ${BOLD}Generators${RESET} (List, Cluster, Git Directory, Matrix) to synthesize Applications."
    echo -e "  • A single ApplicationSet deploys to ${BOLD}dev${RESET}, ${BOLD}staging${RESET}, and ${BOLD}production${RESET} without duplication."
    echo -e "  • Ideal for multi-tenant, multi-cluster, or multi-environment enterprise platforms."
    echo ""
    echo -e "${BLUE}--- ApplicationSet: argocd/apps/03-applicationset/applicationset-environments.yaml ---${RESET}"
    cat "${REPO_ROOT}/argocd/apps/03-applicationset/applicationset-environments.yaml"
    echo ""
    if has_cluster; then
        echo -e "${CYAN}Cluster connection detected!${RESET}"
        if [ "$AUTO_MODE" = false ]; then
            read -p "Do you want to apply the ApplicationSet to Argo CD? (y/N): " -r APPSET_APPLY
            if [[ "$APPSET_APPLY" =~ ^[Yy]$ ]]; then
                echo -e "${GREEN}Applying ApplicationSet to Argo CD...${RESET}"
                kubectl apply -f "${REPO_ROOT}/argocd/apps/03-applicationset/applicationset-environments.yaml" || true
                kubectl get applicationset -n argocd 2>/dev/null || true
            fi
        fi
    fi
    pause
}

run_guided_tour() {
    step_overview
    step_01
    step_02
    step_03
    step_04
    step_05
    step_06
    step_07
    step_08
    step_09
    step_10
    header
    echo -e "${GREEN}🎉 Full guided tour completed!${RESET}\n"
    echo -e "You explored all core features of Argo Workflows and advanced patterns of Argo CD."
    echo -e "Check ${BOLD}README.md${RESET} and ${BOLD}README.pt-BR.md${RESET} for detailed architecture documentation."
    pause
}

interactive_menu() {
    while true; do
        header
        echo -e "${BOLD}Select a demonstration topic:${RESET}\n"
        echo -e "  ${CYAN}1)${RESET} Architecture Overview: Argo Workflows + Argo CD"
        echo -e "  ${CYAN}2)${RESET} [Workflows 01] Hello World (Single Container Step)"
        echo -e "  ${CYAN}3)${RESET} [Workflows 02] Sequential & Parallel Steps"
        echo -e "  ${CYAN}4)${RESET} [Workflows 03] DAG Pipeline (Directed Acyclic Graph)"
        echo -e "  ${CYAN}5)${RESET} [Workflows 04] Artifacts & Parameters Passing"
        echo -e "  ${CYAN}6)${RESET} [Workflows 05] Loops & Conditionals"
        echo -e "  ${CYAN}7)${RESET} [Workflows 06] Production CI/CD Pipeline"
        echo -e "  ${CYAN}8)${RESET} [Workflows 07] Reusable WorkflowTemplates"
        echo -e "  ${CYAN}9)${RESET} [Argo CD 01]   Basic Application & Kustomize Sample"
        echo -e " ${CYAN}10)${RESET} [Argo CD 02]   App of Apps Pattern"
        echo -e " ${CYAN}11)${RESET} [Argo CD 03]   ApplicationSet Multi-Environment"
        echo -e " ${GREEN}12)${RESET} ${BOLD}Run Complete Guided Tour (All in sequence)${RESET}"
        echo -e "  ${YELLOW}0)${RESET} Exit"
        echo ""
        read -p "Choose an option [0-12]: " -r OPTION

        case "$OPTION" in
            1) step_overview ;;
            2) step_01 ;;
            3) step_02 ;;
            4) step_03 ;;
            5) step_04 ;;
            6) step_05 ;;
            7) step_06 ;;
            8) step_07 ;;
            9) step_08 ;;
            10) step_09 ;;
            11) step_10 ;;
            12) run_guided_tour ;;
            0) echo -e "\n${GREEN}Thank you for exploring Argo Showcase!${RESET}"; exit 0 ;;
            *) echo -e "\n${RED}Invalid option.${RESET}"; sleep 1 ;;
        esac
    done
}

if [ "$AUTO_MODE" = true ]; then
    run_guided_tour
else
    interactive_menu
fi
