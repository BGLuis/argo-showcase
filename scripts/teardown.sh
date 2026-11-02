#!/usr/bin/env bash
# ==============================================================================
# scripts/teardown.sh
# Clean teardown for local Argo Showcase cluster and background port-forwards
# ==============================================================================

set -euo pipefail

export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"

BOLD="\033[1m"
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
MAGENTA="\033[1;35m"
RESET="\033[0m"

CLUSTER_NAME="${CLUSTER_NAME:-argo-showcase}"

echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${MAGENTA}║             ARGO SHOWCASE: TEARDOWN & CLEANUP                        ║${RESET}"
echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# 1. Terminate background port-forward processes matching argo
echo -e "${CYAN}ℹ [INFO]${RESET} Checking for lingering kubectl port-forwards..."
pkill -f "kubectl.*port-forward.*(8080|2746)" 2>/dev/null && echo -e "${GREEN}✔ [OK]${RESET} Stopped kubectl port-forward processes." || true
rm -f /tmp/argocd-pf.log /tmp/argo-wf-pf.log

DELETED_LOCAL=false

# 2. Check k3d cluster
if command -v k3d &>/dev/null; then
    if k3d cluster list 2>/dev/null | grep -q "^${CLUSTER_NAME}\b"; then
        echo -e "${CYAN}ℹ [INFO]${RESET} Deleting k3d cluster '${CLUSTER_NAME}'..."
        k3d cluster delete "${CLUSTER_NAME}"
        DELETED_LOCAL=true
        echo -e "${GREEN}✔ [OK]${RESET} k3d cluster '${CLUSTER_NAME}' deleted."
    fi
fi

# 3. Check kind cluster
if command -v kind &>/dev/null; then
    if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}\$"; then
        echo -e "${CYAN}ℹ [INFO]${RESET} Deleting kind cluster '${CLUSTER_NAME}'..."
        kind delete cluster --name "${CLUSTER_NAME}"
        DELETED_LOCAL=true
        echo -e "${GREEN}✔ [OK]${RESET} kind cluster '${CLUSTER_NAME}' deleted."
    fi
fi

# 4. If no local cluster was deleted and current context is an existing cluster, offer to delete showcase namespaces
if [ "$DELETED_LOCAL" = false ]; then
    CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null || echo "none")
    if [[ "$CURRENT_CONTEXT" != "none" && "$CURRENT_CONTEXT" != *"k3d-"* && "$CURRENT_CONTEXT" != *"kind-"* ]]; then
        echo -e "${YELLOW}⚠ [WARN]${RESET} Current kubectl context is '${CURRENT_CONTEXT}' (external/existing cluster)."
        read -p "Do you want to delete showcase namespaces (sample-app-dev, sample-app-prod, app-frontend, app-backend, argo, argocd)? (y/N): " -r CONFIRM
        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
            kubectl delete namespace sample-app-dev sample-app-prod app-frontend app-backend argo argocd --ignore-not-found=true
            echo -e "${GREEN}✔ [OK]${RESET} Namespaces deleted from '${CURRENT_CONTEXT}'."
        fi
    fi
fi

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${GREEN}✔ Cleanup completed successfully! All resources released.${RESET}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════════════${RESET}"
