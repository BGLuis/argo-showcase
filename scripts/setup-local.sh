#!/usr/bin/env bash
# ==============================================================================
# scripts/setup-local.sh
# Automated local cluster bootstrap (k3d / kind) with Argo CD & Argo Workflows
# ==============================================================================

set -euo pipefail

export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"

# ANSI color styles
BOLD="\033[1m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
MAGENTA="\033[1;35m"
RESET="\033[0m"

CLUSTER_NAME="${CLUSTER_NAME:-argo-showcase}"
ARGO_WORKFLOWS_VERSION="${ARGO_WORKFLOWS_VERSION:-v3.5.5}"

log_info() { echo -e "${CYAN}ℹ [INFO]${RESET} $*"; }
log_ok()   { echo -e "${GREEN}✔ [OK]${RESET} $*"; }
log_warn() { echo -e "${YELLOW}⚠ [WARN]${RESET} $*"; }
log_err()  { echo -e "${RED}✖ [ERROR]${RESET} $*"; }

banner() {
    echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${MAGENTA}║      ARGO SHOWCASE: LOCAL CLUSTER BOOTSTRAP (GitOps + CI/CD)         ║${RESET}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

check_prerequisites() {
    log_info "Checking host dependencies..."

    if ! command -v docker &>/dev/null; then
        log_err "Docker is required but not installed (or not in PATH)."
        log_err "Please install Docker and ensure the docker daemon is running."
        exit 1
    fi

    if ! docker info &>/dev/null; then
        log_err "Docker daemon is not running or current user lacks permissions."
        exit 1
    fi
    log_ok "Docker daemon is operational."

    if ! command -v kubectl &>/dev/null; then
        log_err "kubectl is required but not found in PATH."
        exit 1
    fi
    log_ok "kubectl CLI detected."

    PROVIDER=""
    if kubectl cluster-info &>/dev/null && [ "${FORCE_NEW_CLUSTER:-false}" != "true" ]; then
        CURRENT_CTX=$(kubectl config current-context 2>/dev/null || echo "current")
        PROVIDER="existing"
        log_ok "Active Kubernetes cluster detected ('${CURRENT_CTX}'). Using existing cluster."
    elif command -v k3d &>/dev/null; then
        PROVIDER="k3d"
        log_ok "Using k3d as Kubernetes cluster provider."
    elif command -v kind &>/dev/null; then
        PROVIDER="kind"
        log_ok "Using kind as Kubernetes cluster provider."
    else
        log_warn "Neither 'k3d' nor 'kind' was detected in PATH, and no active cluster was found."
        echo ""
        echo -e "${BOLD}Install k3d (Recommended - fastest startup):${RESET}"
        echo "  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash"
        echo ""
        echo -e "${BOLD}Or install kind:${RESET}"
        echo "  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64 && chmod +x ./kind && sudo mv ./kind /usr/local/bin/"
        echo ""
        exit 1
    fi
}

create_cluster() {
    if [ "$PROVIDER" = "existing" ]; then
        log_info "Using active cluster context ($(kubectl config current-context)). Skipping cluster creation."
        return 0
    fi

    log_info "Provisioning local Kubernetes cluster '${CLUSTER_NAME}' via ${PROVIDER}..."

    if [ "$PROVIDER" = "k3d" ]; then
        if k3d cluster list 2>/dev/null | grep -q "^${CLUSTER_NAME}\b"; then
            log_warn "k3d cluster '${CLUSTER_NAME}' already exists. Skipping creation."
        else
            log_info "Creating k3d cluster '${CLUSTER_NAME}'..."
            k3d cluster create "${CLUSTER_NAME}" --wait
            log_ok "k3d cluster '${CLUSTER_NAME}' created successfully."
        fi
        k3d kubeconfig merge "${CLUSTER_NAME}" -d -s >/dev/null 2>&1 || true
        kubectl config use-context "k3d-${CLUSTER_NAME}" >/dev/null 2>&1 || true
    elif [ "$PROVIDER" = "kind" ]; then
        if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}\$"; then
            log_warn "kind cluster '${CLUSTER_NAME}' already exists. Skipping creation."
        else
            log_info "Creating kind cluster '${CLUSTER_NAME}'..."
            kind create cluster --name "${CLUSTER_NAME}"
            log_ok "kind cluster '${CLUSTER_NAME}' created successfully."
        fi
        kind export kubeconfig --name "${CLUSTER_NAME}" >/dev/null 2>&1 || true
        kubectl config use-context "kind-${CLUSTER_NAME}" >/dev/null 2>&1 || true
    fi
}

install_argo_cd() {
    log_info "Installing Argo CD (Declarative Continuous Delivery)..."
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

    log_info "Applying official Argo CD manifests..."
    kubectl apply --server-side --force-conflicts -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

    log_info "Waiting for Argo CD API server deployment to become available..."
    kubectl -n argocd wait --for=condition=available deployment/argocd-server --timeout=300s || {
        log_warn "Argo CD server is still initializing; proceeding with installation..."
    }
    log_ok "Argo CD manifests applied successfully."
}

install_argo_workflows() {
    log_info "Installing Argo Workflows (Kubernetes-native Workflow & Pipeline Engine)..."
    kubectl create namespace argo --dry-run=client -o yaml | kubectl apply -f -

    log_info "Applying Argo Workflows quick-start manifests (including embedded MinIO artifact repository)..."
    kubectl apply -n argo -f "https://github.com/argoproj/argo-workflows/releases/download/${ARGO_WORKFLOWS_VERSION}/quick-start-minimal.yaml"

    log_info "Updating MinIO image to maintained Chainguard registry..."
    kubectl -n argo set image deployment/minio main=cgr.dev/chainguard/minio:latest 2>/dev/null || true

    log_info "Waiting for Argo Workflows server to become available..."
    kubectl -n argo wait --for=condition=available deployment/argo-server --timeout=300s || {
        log_warn "Argo server is still initializing; proceeding with installation..."
    }
    log_ok "Argo Workflows installed successfully."
}

start_port_forwards() {
    log_info "Initiating background port-forwards for instant dashboard access..."
    pkill -f "kubectl.*port-forward.*(8080|2746)" 2>/dev/null || true
    sleep 1

    nohup kubectl -n argocd port-forward svc/argocd-server 8080:443 >/tmp/argocd-pf.log 2>&1 &
    ARGOCD_PF_PID=$!
    nohup kubectl -n argo port-forward svc/argo-server 2746:2746 >/tmp/argo-wf-pf.log 2>&1 &
    ARGO_PF_PID=$!

    sleep 2
    log_ok "Port-forward active for Argo CD on https://localhost:8080 (PID: ${ARGOCD_PF_PID})"
    log_ok "Port-forward active for Argo Workflows on https://localhost:2746 (PID: ${ARGO_PF_PID})"
}

print_summary() {
    echo ""
    echo -e "${GREEN}══════════════════════════════════════════════════════════════════════${RESET}"
    echo -e "${GREEN}🎉 Local Cluster & Argo Ecosystem Ready!${RESET}"
    echo -e "${GREEN}══════════════════════════════════════════════════════════════════════${RESET}"
    echo ""

    # Fetch initial Argo CD admin password
    ARGOCD_PWD="Retrieving..."
    for i in {1..15}; do
        if kubectl -n argocd get secret argocd-initial-admin-secret &>/dev/null; then
            ARGOCD_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d 2>/dev/null || echo "admin")
            break
        fi
        sleep 2
    done

    echo -e "${BOLD}1. Argo CD Web UI (GitOps):${RESET}"
    echo -e "   URL:                   ${CYAN}https://localhost:8080${RESET} (Ignore browser TLS self-signed warning)"
    echo -e "   Status:                ${GREEN}Active in background (port-forward)${RESET}"
    echo -e "   Username:              ${YELLOW}admin${RESET}"
    echo -e "   Password:              ${YELLOW}${ARGOCD_PWD}${RESET}"
    echo -e "   Manual restart:        ${BLUE}kubectl -n argocd port-forward svc/argocd-server 8080:443${RESET}"
    echo ""

    echo -e "${BOLD}2. Argo Workflows Web UI (Pipelines):${RESET}"
    echo -e "   URL:                   ${CYAN}https://localhost:2746${RESET}"
    echo -e "   Status:                ${GREEN}Active in background (port-forward)${RESET}"
    echo -e "   Authentication:        ${YELLOW}Server auth mode (No login token required for local demo)${RESET}"
    echo -e "   Manual restart:        ${BLUE}kubectl -n argo port-forward svc/argo-server 2746:2746${RESET}"
    echo ""

    echo -e "${BOLD}3. Next Step - Run Interactive Showcase:${RESET}"
    echo -e "   Execute:               ${GREEN}bash scripts/demo.sh${RESET}"
    echo ""
}

main() {
    banner
    check_prerequisites
    create_cluster
    install_argo_cd
    install_argo_workflows
    start_port_forwards
    print_summary
}

main "$@"
