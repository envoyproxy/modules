#!/bin/bash -e


CURRENT_SCRIPT_DIR="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
MODULE_NAME=$1

if [ ! -d "${CURRENT_SCRIPT_DIR}/${MODULE_NAME}" ]; then
    echo "Module directory ${MODULE_NAME} does not exist."
    exit 1
fi

cleanup () {
    echo "Cleaning up module: ${MODULE_NAME}"

    local code="$?"
    if [ $code -ne 0 ]; then
        echo "Verification of module ${MODULE_NAME} failed."
        docker compose -f docker-compose.yaml logs
    fi

    down_args=(--remove-orphans)
    if [[ -n "$DOCKER_RMI_CLEANUP" ]]; then
        down_args+=(--rmi all)
    fi

    docker compose -f docker-compose.yaml down "${down_args[@]}" -v

    popd || exit 1

    exit $code
}

verify () {
    echo "Verifying module: ${MODULE_NAME}"

    pushd "${CURRENT_SCRIPT_DIR}/${MODULE_NAME}" || exit 1

    docker compose -f docker-compose.yaml up -d --build || {
        echo "Failed to start module ${MODULE_NAME}."
        exit 1
    }

    sleep 5 # Wait for services to start

    python3 verify.py || {
        echo "Verification script not found or failed for module ${MODULE_NAME}."
        exit 1
    }

    echo "Module ${MODULE_NAME} verified successfully."
}

trap cleanup EXIT

verify
