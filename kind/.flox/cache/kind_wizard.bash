bootstrap() {
   # give the user a way to quit the bootstrapping wizard
   check_quit() {
       local input="$1"
       if [ "$input" = ":q" ]; then
           gum style --foreground 9 --bold "Wizard cancelled"
           SHOULD_QUIT=1
       fi
   }

   SHOULD_QUIT=0

   # fetch the latest kubernetes version
   get_latest_version() {
       curl -s "https://registry.hub.docker.com/v2/repositories/kindest/node/tags?page_size=100" | \
           jq -r '.results[].name | select(test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))' | \
           sort -rV | \
           head -n 1
   }

   # inform user about quit option
   gum style --foreground 212 --bold "You can type ':q' at any prompt to quit the wizard"

   # check for a container runtime
   if ! (docker info >/dev/null 2>&1 || podman info >/dev/null 2>&1); then
       gum style --foreground 9 --bold "No container runtime detected."
       gum style --foreground 212 --bold "KIND requires a container runtime like Docker or Podman."
       gum style --foreground 212 --bold "You can remotely activate Flox's Colima container runtime by running:"
       gum style --foreground 10 --bold "flox activate -s -r flox/colima"
       SHOULD_QUIT=1
   fi

   while [ $SHOULD_QUIT -eq 0 ]; do
       # ask do you want to create a new kind configuration?
       if ! gum confirm "Do you want to create a new KIND configuration file?"; then
           gum style --foreground 212 --bold "Exiting without creating a configuration."
           break
       fi

       # get the cluster name
       gum style --foreground 212 --bold "Specify cluster name (e.g., 'dev-cluster'):"
       CLUSTER_NAME=$(gum input --placeholder "kind")
       check_quit "$CLUSTER_NAME"
       [ $SHOULD_QUIT -eq 1 ] && break

       # define config file name based on cluster name
       CONFIG_FILE="${CLUSTER_NAME}-kind.yaml"

       # default variables
       K8S_VERSION=${1:-"latest"}
       NODE_COUNT=${2:-4}

       # prompt for K8s version and node count
       gum style --foreground 212 --bold "Specify Kubernetes version (e.g., 'v1.29.2' or 'latest'):"
       K8S_VERSION=$(gum input --value "${K8S_VERSION}")
       check_quit "$K8S_VERSION"
       [ $SHOULD_QUIT -eq 1 ] && break

       gum style --foreground 212 --bold "Specify number of worker nodes (e.g., 3):"
       NODE_COUNT=$(gum input --value "${NODE_COUNT}")
       check_quit "$NODE_COUNT"
       [ $SHOULD_QUIT -eq 1 ] && break

       # fetch the latest k8s version if 'latest' is specified
       if [ "$K8S_VERSION" == "latest" ]; then
           K8S_VERSION=$(get_latest_version)
       fi

       # create the kind yaml file
       cat <<EOFK > "$CONFIG_FILE"
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: ${CLUSTER_NAME}
nodes:
 - role: control-plane
   image: kindest/node:${K8S_VERSION}
EOFK

       for i in $(seq 1 $NODE_COUNT); do
           cat <<EOFK >> "$CONFIG_FILE"
 - role: worker
   image: kindest/node:${K8S_VERSION}
EOFK
       done

       gum style --foreground 10 --bold "Created configuration file: ${CONFIG_FILE}"

       if gum confirm "Would you like to create your KIND cluster?"; then
           kind create cluster --config "${CONFIG_FILE}"
       fi
       break
   done
}
