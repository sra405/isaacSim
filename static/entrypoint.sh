#!/bin/bash
set -e

# Source ROS2 environment (sets LD_LIBRARY_PATH dynamically)
source /opt/ros/${ROS_DISTRO}/setup.bash

# Add Isaac Sim ROS2 bridge libraries
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/isaac-sim/exts/isaacsim.ros2.bridge/${ROS_DISTRO}/lib"

# Execute the command passed to the container
exec "$@"
