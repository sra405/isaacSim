#!/bin/bash
set -e

# Source ROS2 environment (sets LD_LIBRARY_PATH dynamically)
source /opt/ros/${ROS_DISTRO}/setup.bash

# Add Isaac Sim ROS2 bridge libraries
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/isaac-sim/exts/isaacsim.ros2.bridge/${ROS_DISTRO}/lib"

# If no command provided, start Isaac Sim headless with livestream
if [ $# -eq 0 ]; then
    PUBLIC_IP=$(curl -s ifconfig.me || echo "localhost")
    exec ./runheadless.sh \
        --/app/livestream/publicEndpointAddress="${PUBLIC_IP}" \
        --/app/livestream/port=49100
fi

# Execute the command passed to the container
exec "$@"
