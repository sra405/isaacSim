#!/bin/bash
set -e

# Isaac Sim uses Python 3.11, but ROS Jazzy ships Python 3.12 bindings.
# Use Isaac Sim's internal ROS2 bridge (compiled for Python 3.11) by setting
# PYTHONPATH BEFORE sourcing ROS to override system rclpy.
ISAAC_ROS_BRIDGE="/isaac-sim/exts/isaacsim.ros2.bridge/${ROS_DISTRO}"
export PYTHONPATH="${ISAAC_ROS_BRIDGE}/lib/python3.11/site-packages:${PYTHONPATH}"

# Source ROS2 environment (sets LD_LIBRARY_PATH dynamically)
source /opt/ros/${ROS_DISTRO}/setup.bash

# Add Isaac Sim ROS2 bridge libraries (must come BEFORE system ROS libs)
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
