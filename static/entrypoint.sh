#!/bin/bash
set -e

# Isaac Sim uses Python 3.11, ROS Jazzy has Python 3.12 bindings.
# DO NOT source system ROS setup.bash - it conflicts with Isaac Sim's internal rclpy.
# Isaac Sim's ROS2 bridge extension handles ROS2 communication internally.

ISAAC_ROS_BRIDGE="/isaac-sim/exts/isaacsim.ros2.bridge/${ROS_DISTRO}"

# Ensure Isaac Sim's ROS2 bridge libs are in LD_LIBRARY_PATH
export LD_LIBRARY_PATH="${ISAAC_ROS_BRIDGE}/lib:${LD_LIBRARY_PATH}"

# If no command provided, start Isaac Sim headless with livestream
if [ $# -eq 0 ]; then
    PUBLIC_IP=$(curl -s ifconfig.me || echo "localhost")
    exec ./runheadless.sh \
        --/app/livestream/publicEndpointAddress="${PUBLIC_IP}" \
        --/app/livestream/port=49100
fi

# Execute the command passed to the container
exec "$@"
