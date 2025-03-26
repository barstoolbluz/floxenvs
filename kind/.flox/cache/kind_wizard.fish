function bootstrap
    function check_quit
        set -l input $argv[1]
        if test "$input" = ":q"
            gum style --foreground 9 --bold "Wizard cancelled"
            return 1
        end
        return 0
    end

    function get_latest_version
        curl -s "https://registry.hub.docker.com/v2/repositories/kindest/node/tags?page_size=100" | \
            jq -r '.results[].name | select(test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))' | \
            sort -rV | \
            head -n 1
    end

    # should we quit?
    set -l SHOULD_QUIT 0

    gum style --foreground 212 --bold "You can type ':q' at any prompt to quit the wizard"

    # does / does not container runtime exist?
    if not command -v docker >/dev/null 2>&1 && not command -v podman >/dev/null 2>&1
        gum style --foreground 9 --bold "No container runtime detected."
        gum style --foreground 212 --bold "KIND requires a container runtime like Docker or Podman."
        gum style --foreground 212 --bold "You can remotely activate Flox's Colima container runtime by running:"
        gum style --foreground 10 --bold "flox activate -s -r flox/colima"
        set SHOULD_QUIT 1
    end

    while test $SHOULD_QUIT -eq 0
        # Ask about creating new kind configuration
        if not gum confirm "Do you want to create a new KIND configuration file?"
            gum style --foreground 212 --bold "Exiting without creating a configuration."
            break
        end

        # get cluster name
        gum style --foreground 212 --bold "Specify cluster name (e.g., 'dev-cluster'):"
        set -l CLUSTER_NAME (gum input --placeholder "kind")
        if not check_quit "$CLUSTER_NAME"
            set SHOULD_QUIT 1
            break
        end
        
        # Use default "kind" if empty
        test -z "$CLUSTER_NAME" && set CLUSTER_NAME "kind"

        # define config file
        set -l CONFIG_FILE "$CLUSTER_NAME-kind.yaml"

        # set default variables
        set -l K8S_VERSION $argv[1]
        test -z "$K8S_VERSION" && set K8S_VERSION "latest"
        
        set -l NODE_COUNT $argv[2]
        test -z "$NODE_COUNT" && set NODE_COUNT 4

        # prompt for K8s version + node count
        gum style --foreground 212 --bold "Specify Kubernetes version (e.g., 'v1.29.2' or 'latest'):"
        set K8S_VERSION (gum input --value "$K8S_VERSION")
        if not check_quit "$K8S_VERSION"
            set SHOULD_QUIT 1
            break
        end

        gum style --foreground 212 --bold "Specify number of worker nodes (e.g., 3):"
        set NODE_COUNT (gum input --value "$NODE_COUNT")
        if not check_quit "$NODE_COUNT"
            set SHOULD_QUIT 1
            break
        end

        # fetch latest k8s version if needed
        if test "$K8S_VERSION" = "latest"
            set K8S_VERSION (get_latest_version)
        end

        # create the KIND config
        echo "kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: $CLUSTER_NAME
nodes:
- role: control-plane
  image: kindest/node:$K8S_VERSION" > "$CONFIG_FILE"

        for i in (seq 1 $NODE_COUNT)
            echo "- role: worker
  image: kindest/node:$K8S_VERSION" >> "$CONFIG_FILE"
        end

        gum style --foreground 10 --bold "Created configuration file: $CONFIG_FILE"

        if gum confirm "Would you like to create your KIND cluster?"
            kind create cluster --config "$CONFIG_FILE"
        end
        break
    end
end
