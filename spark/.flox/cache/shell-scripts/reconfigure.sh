#!/bin/bash
# reconfigure.sh - Interactive Spark configuration wizard for Flox environment

clear

gum style \
    --border rounded \
    --border-foreground 240 \
    --padding "1 2" \
    --margin "1 0" \
    --width 70 \
    "$(gum style --foreground 27 --bold 'Apache Spark Configuration')
    
$(gum style --foreground 240 'First-time setup for your Apache Spark cluster')"

# Ensure defaults are set
DEFAULT_SPARK_MODE="master"
DEFAULT_SPARK_HOST="localhost"
DEFAULT_SPARK_PORT="7077"
DEFAULT_SPARK_WEBUI_PORT="8080"
DEFAULT_SPARK_WORKER_CORES="2"
DEFAULT_SPARK_WORKER_MEMORY="2g"
DEFAULT_SPARK_DATA_DIR="${FLOX_ENV_CACHE}/spark-data"
DEFAULT_SPARK_LOG_DIR="${FLOX_ENV_CACHE}/spark-logs"

# Create directories
mkdir -p "$DEFAULT_SPARK_DATA_DIR" >/dev/null 2>&1
mkdir -p "$DEFAULT_SPARK_LOG_DIR" >/dev/null 2>&1

echo ""
if gum confirm "$(gum style --foreground 240 'Would you like to customize your Spark configuration?')" --default=false; then
    echo "$(gum style --foreground 240 'Press Enter to accept the default values shown in [brackets]')"
    echo ""
    
    SPARK_MODE=$(gum choose --header "Select Spark node type:" "master" "worker")
    
    if [ "$SPARK_MODE" = "master" ]; then
        SPARK_HOST=$(gum input --placeholder "[${DEFAULT_SPARK_HOST}]" --value "$DEFAULT_SPARK_HOST" --prompt "Hostname/IP: ")
        SPARK_PORT=$(gum input --placeholder "[${DEFAULT_SPARK_PORT}]" --value "$DEFAULT_SPARK_PORT" --prompt "Port: ")
        SPARK_WEBUI_PORT=$(gum input --placeholder "[${DEFAULT_SPARK_WEBUI_PORT}]" --value "$DEFAULT_SPARK_WEBUI_PORT" --prompt "Web UI Port: ")
        
        # Build the master URL
        SPARK_MASTER_URL="spark://$SPARK_HOST:$SPARK_PORT"
    else
        SPARK_HOST="worker"
        SPARK_PORT=""
        SPARK_WEBUI_PORT=""
        SPARK_MASTER_URL=$(gum input --placeholder "spark://host:port" --prompt "Master URL: ")
        SPARK_WORKER_CORES=$(gum input --placeholder "[${DEFAULT_SPARK_WORKER_CORES}]" --value "$DEFAULT_SPARK_WORKER_CORES" --prompt "Worker Cores: ")
        SPARK_WORKER_MEMORY=$(gum input --placeholder "[${DEFAULT_SPARK_WORKER_MEMORY}]" --value "$DEFAULT_SPARK_WORKER_MEMORY" --prompt "Worker Memory: ")
    fi
    
    if gum confirm "Use default directories for Spark data and logs?" --default=true; then
        SPARK_DATA_DIR="$DEFAULT_SPARK_DATA_DIR"
        SPARK_LOG_DIR="$DEFAULT_SPARK_LOG_DIR"
    else
        SPARK_DATA_DIR=$(gum input --placeholder "[${DEFAULT_SPARK_DATA_DIR}]" --value "$DEFAULT_SPARK_DATA_DIR" --prompt "Spark Data Directory: ")
        SPARK_LOG_DIR=$(gum input --placeholder "[${DEFAULT_SPARK_LOG_DIR}]" --value "$DEFAULT_SPARK_LOG_DIR" --prompt "Spark Log Directory: ")
        
        # Create custom directories if they don't exist
        mkdir -p "$SPARK_DATA_DIR" >/dev/null 2>&1
        mkdir -p "$SPARK_LOG_DIR" >/dev/null 2>&1
    fi
else
    echo "$(gum style --foreground 240 'Using default configuration:')"
    
    # For simplicity, default to master mode in the non-interactive path
    SPARK_MODE="$DEFAULT_SPARK_MODE"
    SPARK_HOST="$DEFAULT_SPARK_HOST"
    SPARK_PORT="$DEFAULT_SPARK_PORT"
    SPARK_WEBUI_PORT="$DEFAULT_SPARK_WEBUI_PORT"
    SPARK_MASTER_URL="spark://$SPARK_HOST:$SPARK_PORT"
    SPARK_WORKER_CORES="$DEFAULT_SPARK_WORKER_CORES"
    SPARK_WORKER_MEMORY="$DEFAULT_SPARK_WORKER_MEMORY"
    SPARK_DATA_DIR="$DEFAULT_SPARK_DATA_DIR"
    SPARK_LOG_DIR="$DEFAULT_SPARK_LOG_DIR"
    
    echo "$(gum style --foreground 240 "  Mode: ${SPARK_MODE}")"
    echo "$(gum style --foreground 240 "  Host: ${SPARK_HOST}")"
    echo "$(gum style --foreground 240 "  Port: ${SPARK_PORT}")"
    echo "$(gum style --foreground 240 "  Web UI Port: ${SPARK_WEBUI_PORT}")"
    echo "$(gum style --foreground 240 "  Master URL: ${SPARK_MASTER_URL}")"
    echo "$(gum style --foreground 240 "  Data Directory: ${SPARK_DATA_DIR}")"
    echo "$(gum style --foreground 240 "  Log Directory: ${SPARK_LOG_DIR}")"
    echo ""
fi

# Determine the network configuration
echo ""
echo "$(gum style --foreground 240 'Configuring network settings:')"

# Get the machine's IP address (first non-loopback address)
DETECTED_IP=$(hostname -I | awk '{print $1}')

if [ "$SPARK_MODE" = "master" ]; then
    # Ask if user wants to use the detected IP or specify a different one
    echo "$(gum style --foreground 240 "Detected IP address: ${DETECTED_IP}")"
    if gum confirm "$(gum style --foreground 240 'Use this IP address for advertising the Spark master?')" --default=true; then
        SPARK_ADVERTISE_IP="$DETECTED_IP"
    else
        SPARK_ADVERTISE_IP=$(gum input --placeholder "[${DETECTED_IP}]" --value "$DETECTED_IP" --prompt "Advertise IP: ")
    fi
    
    # Set the local binding IP
    SPARK_LOCAL_IP="0.0.0.0"  # Bind to all interfaces
    
    # Update master URL to use the advertised IP
    SPARK_MASTER_URL="spark://$SPARK_ADVERTISE_IP:$SPARK_PORT"
else
    # For worker mode
    SPARK_LOCAL_IP="$DETECTED_IP"
    SPARK_ADVERTISE_IP="$SPARK_LOCAL_IP"
fi

# Save configuration
cat > "$FLOX_ENV_CACHE/spark_config.sh" << EOF
# Spark configuration generated by Flox environment
SPARK_MODE="$SPARK_MODE"
SPARK_HOST="$SPARK_HOST"
SPARK_PORT="$SPARK_PORT"
SPARK_WEBUI_PORT="$SPARK_WEBUI_PORT"
SPARK_WORKER_CORES="$SPARK_WORKER_CORES"
SPARK_WORKER_MEMORY="$SPARK_WORKER_MEMORY"
SPARK_MASTER_URL="$SPARK_MASTER_URL"
SPARK_LOG_DIR="$SPARK_LOG_DIR"
SPARK_WORKER_DIR="$SPARK_DATA_DIR"
SPARK_LOCAL_IP="$SPARK_LOCAL_IP"
SPARK_ADVERTISE_IP="$SPARK_ADVERTISE_IP"
EOF

# Export environment variables for current session
export SPARK_HOME="$(dirname $(which spark-submit))/.."
export SPARK_LOG_DIR="$SPARK_LOG_DIR"
export SPARK_WORKER_DIR="$SPARK_DATA_DIR"
export SPARK_MODE="$SPARK_MODE"
export SPARK_HOST="$SPARK_HOST"
export SPARK_PORT="$SPARK_PORT"
export SPARK_WEBUI_PORT="$SPARK_WEBUI_PORT"
export SPARK_WORKER_CORES="$SPARK_WORKER_CORES"
export SPARK_WORKER_MEMORY="$SPARK_WORKER_MEMORY"
export SPARK_MASTER_URL="$SPARK_MASTER_URL"
export SPARK_LOCAL_IP="$SPARK_LOCAL_IP"
export SPARK_ADVERTISE_IP="$SPARK_ADVERTISE_IP"

# Set master-specific variables if in master mode
if [ "$SPARK_MODE" = "master" ]; then
    export SPARK_MASTER_HOST="$SPARK_ADVERTISE_IP"
    export SPARK_MASTER_PORT="$SPARK_PORT"
    export SPARK_MASTER_WEBUI_PORT="$SPARK_WEBUI_PORT"
fi

echo ""
echo "$(gum style --foreground 34 --bold "✓ Spark configuration saved!")"
echo "$(gum style --foreground 212 "You can now start Spark with: flox services start")"
