#!/bin/bash
# Kafka helper scripts for common operations

# Source configuration
if [ -f "$FLOX_ENV_CACHE/kafka_config.sh" ]; then
    source "$FLOX_ENV_CACHE/kafka_config.sh"
else
    echo "No Kafka configuration found. Run bootstrap first."
    exit 1
fi

# Function to create a topic with intelligent defaults
kreate() {
    # Help message
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        echo "Usage: kreate <topic_name> [partitions] [replication-factor]"
        echo ""
        echo "Environment variables for defaults:"
        echo "  KAFKA_DEFAULT_PARTITIONS    (default: varies by mode)"
        echo "  KAFKA_DEFAULT_REPLICATION   (default: varies by mode)"
        echo ""
        echo "Example:"
        echo "  kreate my-topic                    # Uses intelligent defaults"
        echo "  kreate my-topic 6                  # 6 partitions, default replication"
        echo "  kreate my-topic 6 2                # 6 partitions, replication factor 2"
        return 0
    fi

    if [ -z "$1" ]; then
        echo "Usage: kreate <topic_name> [partitions] [replication-factor]"
        return 1
    fi

    TOPIC_NAME="$1"
    
    # Determine the bootstrap server first (we'll need it for broker count)
    if [[ "$KAFKA_MODE" == "kraft-"* ]] && [[ "$PROCESS_ROLES" == *"broker"* ]]; then
        BOOTSTRAP_SERVER="localhost:$KAFKA_PORT"
    elif [ "$KAFKA_MODE" = "client" ]; then
        BOOTSTRAP_SERVER="$BOOTSTRAP_SERVERS"
    else
        echo "Please specify bootstrap server:"
        read -p "Bootstrap server [localhost:9092]: " BOOTSTRAP_SERVER
        BOOTSTRAP_SERVER="${BOOTSTRAP_SERVER:-localhost:9092}"
    fi
    
    # Try to get broker count for intelligent defaults
    BROKER_COUNT=$(kafka-broker-api-versions.sh --bootstrap-server "$BOOTSTRAP_SERVER" 2>/dev/null | grep -c "id:" || echo "0")
    
    # Intelligent partition defaults based on mode and use case
    if [ -n "$KAFKA_DEFAULT_PARTITIONS" ]; then
        DEFAULT_PARTITIONS="$KAFKA_DEFAULT_PARTITIONS"
    else
        case "$KAFKA_MODE" in
            "kraft-combined")
                DEFAULT_PARTITIONS="3"  # Small for single-node dev
                ;;
            "kraft-broker")
                # In production, partitions often = number of brokers or multiple thereof
                if [ "$BROKER_COUNT" -gt 0 ]; then
                    DEFAULT_PARTITIONS=$((BROKER_COUNT * 2))  # 2 partitions per broker
                else
                    DEFAULT_PARTITIONS="6"  # Fallback for 2-3 brokers
                fi
                ;;
            "client")
                DEFAULT_PARTITIONS="3"  # Conservative for client mode
                ;;
            *)
                DEFAULT_PARTITIONS="3"
                ;;
        esac
    fi
    PARTITIONS="${2:-$DEFAULT_PARTITIONS}"
    
    # Intelligent replication defaults
    if [ -n "$KAFKA_DEFAULT_REPLICATION" ]; then
        DEFAULT_REPLICATION="$KAFKA_DEFAULT_REPLICATION"
    else
        case "$KAFKA_MODE" in
            "kraft-combined")
                DEFAULT_REPLICATION="1"  # Single node can't replicate
                ;;
            "kraft-broker")
                # Production standard is 3, but check broker count
                if [ "$BROKER_COUNT" -gt 0 ]; then
                    # Set replication to min(3, broker_count)
                    DEFAULT_REPLICATION=$(( BROKER_COUNT < 3 ? BROKER_COUNT : 3 ))
                else
                    DEFAULT_REPLICATION="3"  # Assume production standard
                fi
                ;;
            "client")
                DEFAULT_REPLICATION="1"  # Conservative for client mode
                ;;
            *)
                DEFAULT_REPLICATION="1"
                ;;
        esac
    fi
    REPLICATION="${3:-$DEFAULT_REPLICATION}"

    # Check for common issues and warn the user
    if [ "$REPLICATION" -gt "$BROKER_COUNT" ] && [ "$BROKER_COUNT" -gt 0 ]; then
        echo "Warning: Replication factor ($REPLICATION) is greater than available brokers ($BROKER_COUNT)."
        echo "This will cause topic creation to fail. Adjusting to $BROKER_COUNT."
        REPLICATION="$BROKER_COUNT"
    fi
    
    # Special consideration for topic purpose
    if [[ "$TOPIC_NAME" == *"log"* ]] || [[ "$TOPIC_NAME" == *"audit"* ]] || [[ "$TOPIC_NAME" == *"critical"* ]]; then
        if [ "$REPLICATION" -lt 3 ] && [ "$BROKER_COUNT" -ge 3 ]; then
            echo "Note: Topic name suggests this might be important data (contains 'log', 'audit', or 'critical')."
            echo "Consider using replication factor of 3 for better durability."
            echo ""
        fi
    fi

    # Show what we're doing
    echo "Creating topic: ${TOPIC_NAME}"
    echo "  Partitions:        ${PARTITIONS} $([ "$PARTITIONS" = "$DEFAULT_PARTITIONS" ] && [ "$2" = "" ] && echo "(intelligent default)")"
    echo "  Replication:       ${REPLICATION} $([ "$REPLICATION" = "$DEFAULT_REPLICATION" ] && [ "$3" = "" ] && echo "(intelligent default)")"
    echo "  Bootstrap server:  ${BOOTSTRAP_SERVER}"
    echo "  Detected brokers:  ${BROKER_COUNT}"
    echo ""

    # Create the topic
    kafka-topics.sh --create --topic "$TOPIC_NAME" \
      --partitions "$PARTITIONS" \
      --replication-factor "$REPLICATION" \
      --bootstrap-server "$BOOTSTRAP_SERVER"
    
    # If creation was successful, show the topic details
    if [ $? -eq 0 ]; then
        echo ""
        echo "Topic created successfully! Here are the details:"
        kafka-topics.sh --describe --topic "$TOPIC_NAME" --bootstrap-server "$BOOTSTRAP_SERVER"
    fi
}

# Function to list topics
list() {
    # Determine the bootstrap server
    if [[ "$KAFKA_MODE" == "kraft-"* ]] && [[ "$PROCESS_ROLES" == *"broker"* ]]; then
        BOOTSTRAP_SERVER="localhost:$KAFKA_PORT"
    elif [ "$KAFKA_MODE" = "client" ]; then
        BOOTSTRAP_SERVER="$BOOTSTRAP_SERVERS"
    else
        echo "Please specify bootstrap server:"
        read -p "Bootstrap server [localhost:9092]: " BOOTSTRAP_SERVER
        BOOTSTRAP_SERVER="${BOOTSTRAP_SERVER:-localhost:9092}"
    fi

    echo "Listing topics on $BOOTSTRAP_SERVER:"
    kafka-topics.sh --list --bootstrap-server "$BOOTSTRAP_SERVER"
}

# Function to start a console producer
produce() {
    if [ -z "$1" ]; then
      echo "Usage: produce <topic_name>"
      return 1
    fi

    TOPIC_NAME="$1"

    # Determine the bootstrap server
    if [[ "$KAFKA_MODE" == "kraft-"* ]] && [[ "$PROCESS_ROLES" == *"broker"* ]]; then
        BOOTSTRAP_SERVER="localhost:$KAFKA_PORT"
    elif [ "$KAFKA_MODE" = "client" ]; then
        BOOTSTRAP_SERVER="$BOOTSTRAP_SERVERS"
    else
        echo "Please specify bootstrap server:"
        read -p "Bootstrap server [localhost:9092]: " BOOTSTRAP_SERVER
        BOOTSTRAP_SERVER="${BOOTSTRAP_SERVER:-localhost:9092}"
    fi

    echo "Starting console producer for topic: $TOPIC_NAME"
    echo "Type messages and press Enter to send. Press Ctrl+C to exit."
    kafka-console-producer.sh --topic "$TOPIC_NAME" --bootstrap-server "$BOOTSTRAP_SERVER"
}

# Function to start a console consumer
konsume() {
    if [ -z "$1" ]; then
      echo "Usage: konsume <topic_name> [consumer_group]"
      return 1
    fi

    TOPIC_NAME="$1"

    # Set consumer group
    if [ -z "$2" ]; then
        if [ -n "$GROUP_ID" ]; then
            CONSUMER_GROUP="$GROUP_ID"
        else
            CONSUMER_GROUP="console-consumer-$$"
        fi
    else
        CONSUMER_GROUP="$2"
    fi

    # Determine the bootstrap server
    if [[ "$KAFKA_MODE" == "kraft-"* ]] && [[ "$PROCESS_ROLES" == *"broker"* ]]; then
        BOOTSTRAP_SERVER="localhost:$KAFKA_PORT"
    elif [ "$KAFKA_MODE" = "client" ]; then
        BOOTSTRAP_SERVER="$BOOTSTRAP_SERVERS"
    else
        echo "Please specify bootstrap server:"
        read -p "Bootstrap server [localhost:9092]: " BOOTSTRAP_SERVER
        BOOTSTRAP_SERVER="${BOOTSTRAP_SERVER:-localhost:9092}"
    fi

    # Determine offset reset if not set
    FROM_BEGINNING=""
    if [ -z "$AUTO_OFFSET_RESET" ]; then
        read -p "Start from beginning? [y/N]: " FROM_START
        if [[ "$FROM_START" =~ ^[Yy]$ ]]; then
            FROM_BEGINNING="--from-beginning"
        fi
    else
        if [ "$AUTO_OFFSET_RESET" = "earliest" ]; then
            FROM_BEGINNING="--from-beginning"
        fi
    fi

    echo "Starting console consumer for topic: $TOPIC_NAME"
    echo "Consumer group: $CONSUMER_GROUP"
    echo "Press Ctrl+C to exit."
    kafka-console-consumer.sh --topic "$TOPIC_NAME" \
      --bootstrap-server "$BOOTSTRAP_SERVER" \
      --group "$CONSUMER_GROUP" \
      $FROM_BEGINNING
}

# Function to describe a topic
describe() {
    if [ -z "$1" ]; then
      echo "Usage: describe <topic_name>"
      return 1
    fi

    TOPIC_NAME="$1"

    # Determine the bootstrap server
    if [[ "$KAFKA_MODE" == "kraft-"* ]] && [[ "$PROCESS_ROLES" == *"broker"* ]]; then
        BOOTSTRAP_SERVER="localhost:$KAFKA_PORT"
    elif [ "$KAFKA_MODE" = "client" ]; then
        BOOTSTRAP_SERVER="$BOOTSTRAP_SERVERS"
    else
        echo "Please specify bootstrap server:"
        read -p "Bootstrap server [localhost:9092]: " BOOTSTRAP_SERVER
        BOOTSTRAP_SERVER="${BOOTSTRAP_SERVER:-localhost:9092}"
    fi

    echo "Describing topic: $TOPIC_NAME"
    kafka-topics.sh --describe --topic "$TOPIC_NAME" --bootstrap-server "$BOOTSTRAP_SERVER"
}

# Function to check broker status
status() {
    # Determine the bootstrap server
    if [[ "$KAFKA_MODE" == "kraft-"* ]] && [[ "$PROCESS_ROLES" == *"broker"* ]]; then
        BOOTSTRAP_SERVER="localhost:$KAFKA_PORT"
    elif [ "$KAFKA_MODE" = "client" ]; then
        BOOTSTRAP_SERVER="$BOOTSTRAP_SERVERS"
    else
        BOOTSTRAP_SERVER="${BOOTSTRAP_SERVERS:-localhost:9092}"
    fi
    
    echo "Checking Kafka broker status on $BOOTSTRAP_SERVER:"
    kafka-broker-api-versions.sh --bootstrap-server "$BOOTSTRAP_SERVER"
}

topos() {
    echo "$(gum style --foreground 141 --bold 'Kafka Cluster Topology')"
    echo ""

    # Determine bootstrap server
    if [[ "$KAFKA_MODE" == "kraft-"* ]]; then
        # If this is a broker or combined node, use its own address
        if [[ "$PROCESS_ROLES" == *"broker"* ]]; then
            BOOTSTRAP_SERVER="$KAFKA_HOST:$KAFKA_PORT"
        else
            # If this is a controller-only node, try to use a configured broker
            if [ -n "$BOOTSTRAP_SERVERS" ]; then
                BOOTSTRAP_SERVER="$BOOTSTRAP_SERVERS"
            else
                echo "Error: No broker configured for this controller node"
                echo "Please configure with a broker address to view topology"
                return 1
            fi
        fi
    elif [ "$KAFKA_MODE" = "client" ]; then
        # For client mode, use configured bootstrap servers
        BOOTSTRAP_SERVER="$BOOTSTRAP_SERVERS"
    else
        # Fallback: use configured bootstrap servers or warn
        if [ -n "$BOOTSTRAP_SERVERS" ]; then
            BOOTSTRAP_SERVER="$BOOTSTRAP_SERVERS"
        else
            echo "Error: No bootstrap servers configured"
            echo "Please configure bootstrap servers to view topology"
            return 1
        fi
    fi

    echo "$(gum style --foreground 240 'Using bootstrap server: '$BOOTSTRAP_SERVER)"
    echo ""

    # Get cluster metadata
    echo "$(gum style --foreground 212 'Cluster Metadata')"
    kafka-metadata-quorum.sh --bootstrap-server "$BOOTSTRAP_SERVER" describe --status 2>/dev/null || {
        echo "Error: Unable to connect to bootstrap server at $BOOTSTRAP_SERVER"
        return 1
    }

    echo ""
    echo "$(gum style --foreground 212 'Broker Information')"
    # Try multiple methods to get broker information
    if ! kafka-broker-api-versions.sh --bootstrap-server "$BOOTSTRAP_SERVER" 2>/dev/null | grep -E "^[[:space:]]*id:"; then
        # Try alternative: describe cluster
        kafka-metadata-quorum.sh --bootstrap-server "$BOOTSTRAP_SERVER" describe --replication 2>/dev/null || {
            echo "Unable to retrieve detailed broker information"
        }
    fi

    echo ""
    echo "$(gum style --foreground 212 'Current Node Configuration')"
    echo "Mode: $KAFKA_MODE"
    if [ "$KAFKA_MODE" != "client" ]; then
        echo "Node ID: ${KAFKA_NODE_ID:-N/A}"
        echo "Host: ${KAFKA_HOST:-N/A}"
        echo "Port: ${KAFKA_PORT:-N/A}"
        if [ -n "$CONTROLLER_HOST" ]; then
            echo "Controller: ${CONTROLLER_NODE_ID}@${CONTROLLER_HOST}:${CONTROLLER_PORT}"
        fi
    else
        echo "Client connected to: $BOOTSTRAP_SERVERS"
    fi
    if [ -f "$KAFKA_CONFIG_DIR/cluster_id" ]; then
        echo "Cluster ID: $(cat "$KAFKA_CONFIG_DIR/cluster_id")"
    fi

    # Extract observer information and display it properly
    echo ""
    echo "$(gum style --foreground 212 'Cluster Summary')"

    # Parse the quorum information we already have
    local quorum_output=$(kafka-metadata-quorum.sh --bootstrap-server "$BOOTSTRAP_SERVER" describe --status 2>/dev/null)
    
    if [ -n "$quorum_output" ]; then
        # Count voters (controllers)
        local controller_count=$(echo "$quorum_output" | grep -c "CurrentVoters:" || echo "0")
        
        # Count observers (brokers)
        local broker_count=$(echo "$quorum_output" | grep -c "CurrentObservers:" || echo "0")
        
        # Extract actual node information
        local voters=$(echo "$quorum_output" | grep -A5 "CurrentVoters:" | grep "\[" | tr -d '[]' || echo "")
        local observers=$(echo "$quorum_output" | grep -A5 "CurrentObservers:" | grep "\[" | tr -d '[]' || echo "")
        
        if [ -n "$voters" ]; then
            echo "Controllers: $(echo "$voters" | tr ',' '\n' | wc -l | xargs) (Node(s): $voters)"
        else
            echo "Controllers: 0"
        fi
        
        if [ -n "$observers" ]; then
            echo "Brokers: $(echo "$observers" | tr ',' '\n' | wc -l | xargs) (Node(s): $observers observing controller)"
        else
            echo "Brokers: 0"
        fi
        
        echo ""
        echo "Note: Client is connected to broker at $BOOTSTRAP_SERVER"
        
        if [ "$broker_count" -gt 1 ]; then
            echo "Consider connecting to multiple brokers for better fault tolerance"
        fi
    else
        echo "Unable to retrieve cluster information"
    fi
}

# help / informational message 
info() {
    # Build the header content with consistent spacing
    local header_content=$(cat << EOF
$(gum style --foreground 141 --bold 'This is a  F l o x  Apache Kafka Environment (KRaft Mode)')

👉  Manage Kafka Cluster(s):
    $(gum style --foreground 212 'bootstrap')                              Runs interactive Kafka bootstrapping wizard
    $(gum style --foreground 212 'topos')                                  Shows information about Kafka cluster topology

👉  Use Kafka:
    $(gum style --foreground 212 'kreate <topic> [partitions] [rf]')       Creates a new Kafka topic
    $(gum style --foreground 212 'list')                                   Lists all available Kafka topics
    $(gum style --foreground 212 'describe <topic>')                       Shows details for a specific topic
    $(gum style --foreground 212 'status')                                 Checks Kafka broker status
EOF
)

    # Add service start command based on mode
    if [ "$KAFKA_MODE" = "client" ]; then
        header_content+=$(cat << EOF

    $(gum style --foreground 212 'flox services start')                    Start ${CLIENT_TYPE} client(s)
EOF
)
    fi

    header_content+=$(cat << EOF


👉  Start / Stop / Monitor Kafka Service(s):
    $(gum style --foreground 212 'flox services <start|stop|restart>')     Starts/stops/restarts Kafka services
    $(gum style --foreground 212 'flox services status')                   Shows Kafka services status
    $(gum style --foreground 212 'flox services logs kafka')               Shows Kafka logs
                                           (\`--follow\` updates log events in console)

👉  Get Help:
    $(gum style --foreground 212 'readme')                                 View README.md using \`bat\`
    $(gum style --foreground 212 'info')                                   Shows this help message


👉  F l o x  Kafka Environment Details:
      Kafka Mode:         $(gum style --foreground 212 "${KAFKA_MODE:-Not configured}")
EOF
)

    # Add node-specific information based on the mode
    if [ "$KAFKA_MODE" = "kraft-controller" ]; then
        header_content+=$(cat << EOF

      Controller Port:    $(gum style --foreground 212 "${KRAFT_CONTROLLER_PORT}")
      Quorum Voters:      $(gum style --foreground 212 "${CONTROLLER_QUORUM}")
EOF
)
        if [ -f "$KAFKA_CONFIG_DIR/cluster_id" ]; then
            header_content+=$(cat << EOF

      Cluster ID:         $(gum style --foreground 212 "$(cat "$KAFKA_CONFIG_DIR/cluster_id")")
      ⚠️  IMPORTANT: Use this cluster ID when setting up broker nodes
EOF
)
        fi
    elif [ "$KAFKA_MODE" = "kraft-broker" ]; then
        header_content+=$(cat << EOF

      Controller Quorum:  $(gum style --foreground 212 "${CONTROLLER_QUORUM}")
      Listening on:       $(gum style --foreground 212 "${KAFKA_HOST}:${KAFKA_PORT}")
EOF
)
    elif [ "$KAFKA_MODE" = "kraft-combined" ]; then
        header_content+=$(cat << EOF

      Broker Port:        $(gum style --foreground 212 "${KAFKA_PORT}")
      Controller Port:    $(gum style --foreground 212 "${KRAFT_CONTROLLER_PORT}")
EOF
)
        if [ "$ADVANCED_MODE" = "true" ] && [ -n "$CONTROLLER_QUORUM" ]; then
            header_content+=$(cat << EOF

      Quorum Voters:      $(gum style --foreground 212 "${CONTROLLER_QUORUM}")
EOF
)
        fi
        if [ -f "$KAFKA_CONFIG_DIR/cluster_id" ]; then
            header_content+=$(cat << EOF

      Cluster ID:         $(gum style --foreground 212 "$(cat "$KAFKA_CONFIG_DIR/cluster_id")")
EOF
)
        fi
    elif [ "$KAFKA_MODE" = "client" ]; then
        header_content+=$(cat << EOF

      Connected to:       $(gum style --foreground 212 "${BOOTSTRAP_SERVERS}")
      Client Type:        $(gum style --foreground 212 "${CLIENT_TYPE}")
      Topics:             $(gum style --foreground 212 "${KAFKA_TOPICS}")
      Processing Mode:    $(gum style --foreground 212 "${KAFKA_MESSAGE_PROCESSING_MODE}")
EOF
)
        # Add mode-specific information
        if [ "$KAFKA_MESSAGE_PROCESSING_MODE" = "script" ]; then
            header_content+=$(cat << EOF

      Scripts Dir:        $(gum style --foreground 212 "${KAFKA_SCRIPTS_DIR}")
EOF
)
        elif [ "$KAFKA_MESSAGE_PROCESSING_MODE" = "file" ]; then
            header_content+=$(cat << EOF

      Output Dir:         $(gum style --foreground 212 "${KAFKA_MESSAGE_OUTPUT_DIR}")
      Append Mode:        $(gum style --foreground 212 "${KAFKA_FILE_APPEND}")
EOF
)
        fi
        
        # Add advanced settings info if configured
        if [ "$KAFKA_CLIENT_COUNT" != "1" ] || [ "$KAFKA_CLIENT_PARALLEL" = "true" ]; then
            header_content+=$(cat << EOF

      Client Instances:   $(gum style --foreground 212 "${KAFKA_CLIENT_COUNT}")
      Parallel Execution: $(gum style --foreground 212 "${KAFKA_CLIENT_PARALLEL}")
EOF
)
        fi
    fi
    
    # Create the help message with Gum styling
    gum style \
        --border rounded \
        --border-foreground 240 \
        --padding "1 2" \
        --margin "1 0" \
        --width 96 \
        "$header_content"
}

# Show help information (with updated command names)
show_helpers_help() {
    cat << EOF
Kafka Helper Functions:
  kreate <name> [partitions] [replication]   Create a new Kafka topic
  list                                       List all available topics
  describe <name>                            Show details about a topic
  produce <topic>                            Start a console producer
  konsume <topic> [group]                    Start a console consumer
  status                                     Check broker status
  topos                                      Show cluster topology
  info                                       Show this help information
EOF
}

# Main function to handle command-line arguments
main() {
    COMMAND="$1"
    shift

    case "$COMMAND" in
        kreate)
            kreate "$@"
            ;;
        list)
            list
            ;;
        describe)
            describe "$@"
            ;;
        produce)
            produce "$@"
            ;;
        konsume)
            konsume "$@"
            ;;
        status)
            status
            ;;
        topos)
            topos
            ;;
        info)
            info
            ;;
        *)
            show_helpers_help
            ;;
    esac
}
