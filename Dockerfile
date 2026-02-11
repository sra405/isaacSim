ARG ISAAC_SIM_VERSION=5.1.0
ARG ROBOT_ID
ARG ROBOT_MODEL

# Isaac Sim base image (see https://catalog.ngc.nvidia.com/orgs/nvidia/containers/isaac-sim)
FROM nvcr.io/nvidia/isaac-sim:${ISAAC_SIM_VERSION} AS isaac-sim

ARG ROS_DISTRO=jazzy

SHELL ["/bin/bash", "-lc"]

# Switch to root for package installation
USER root

# Following ROS install here - https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html
RUN apt-get update && \
    apt-get install -y --no-install-recommends locales && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    locale

# Install software-properties-common and enable universe repository
RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository universe

# Install curl and add ROS2 apt source
RUN apt-get update && apt-get install -y curl \
    && export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}') \
    && curl -L -o /tmp/ros2-apt-source.deb "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb" \
    && dpkg -i /tmp/ros2-apt-source.deb

# Install ros-dev-tools, update, upgrade, and install ROS Jazzy desktop and base
RUN apt-get update && \
    apt-get install -y ros-dev-tools && \
    apt-get upgrade -y && \
    apt-get install -y \
        ros-${ROS_DISTRO}-desktop ros-${ROS_DISTRO}-ros-base \
        ros-${ROS_DISTRO}-vision-msgs \
        ros-${ROS_DISTRO}-ackermann-msgs && \
    rm -rf /var/lib/apt/lists/*

# Setup ROS2 environment - copy fastdds.xml to system-wide location
COPY static/fastdds.xml /etc/ros/fastdds.xml
COPY static/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /root/.bashrc && \
    echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /isaac-sim/.bashrc && \
    echo "export RMW_IMPLEMENTATION=rmw_fastrtps_cpp" >> /root/.bashrc && \
    echo "export RMW_IMPLEMENTATION=rmw_fastrtps_cpp" >> /isaac-sim/.bashrc && \
    echo "export FASTRTPS_DEFAULT_PROFILES_FILE=/etc/ros/fastdds.xml" >> /root/.bashrc && \
    echo "export FASTRTPS_DEFAULT_PROFILES_FILE=/etc/ros/fastdds.xml" >> /isaac-sim/.bashrc && \
    echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/isaac-sim/exts/isaacsim.ros2.bridge/${ROS_DISTRO}/lib" >> /root/.bashrc && \
    echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/isaac-sim/exts/isaacsim.ros2.bridge/${ROS_DISTRO}/lib" >> /isaac-sim/.bashrc && \
    echo 'export ROS_DOMAIN_ID=30' >> /root/.bashrc && \
    echo 'export ROS_DOMAIN_ID=30' >> /isaac-sim/.bashrc

ENV ROS_DISTRO=${ROS_DISTRO}
ENV FASTRTPS_DEFAULT_PROFILES_FILE=/etc/ros/fastdds.xml
ENV RMW_IMPLEMENTATION=rmw_fastrtps_cpp
ENV ROS_DOMAIN_ID=30

# Use entrypoint to dynamically source ROS2 setup and set LD_LIBRARY_PATH
ENTRYPOINT ["/entrypoint.sh"]

# Switch back to the original user if required by Isaac Sim
USER isaac-sim

# TurtleBot3 stage
# https://docs.isaacsim.omniverse.nvidia.com/5.1.0/ros2_tutorials/tutorial_ros2_turtlebot.html#isaac-sim-app-tutorial-ros2-turtlebot
FROM isaac-sim AS turtlebot3

USER root

# Install xacro for URDF processing
RUN apt-get update && \
    apt-get install -y --no-install-recommends ros-${ROS_DISTRO}-xacro && \
    rm -rf /var/lib/apt/lists/*

# Clone TurtleBot3 repository and process URDF
WORKDIR /isaac-sim
RUN git clone -b ${ROS_DISTRO} https://github.com/ROBOTIS-GIT/turtlebot3.git turtlebot3 && \
    chmod -R 777 turtlebot3/* && \
    cd turtlebot3/turtlebot3_description/urdf && \
    . /opt/ros/${ROS_DISTRO}/setup.sh && \
    xacro ./turtlebot3_burger.urdf "namespace:=/" > tb3_burger_processed.urdf

USER isaac-sim

ENTRYPOINT ["/entrypoint.sh"]

# ---
# The following are the original ROS2 and TurtleBot3 Docker steps for reference.
# Uncomment and adapt as needed for future use.

# # Python setup for scripts
# RUN set -e \
#  && apt-get update \
#  && apt-get install -y --no-install-recommends \
#     git \
#     python3-pip \
#     python3-colcon-common-extensions \
#     python3-rosdep \
#     python3-vcstools \
#     build-essential \
#     python3-bloom \
#     python3-rosdep \
#     fakeroot \
#     debhelper \
#     dh-python
#
# FROM ros2 AS ros2-turtlebot3
#
# # Install ROS2 Packages
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     ros-${ROS_DISTRO}-gazebo-* \
#     ros-${ROS_DISTRO}-cartographer \
#     ros-${ROS_DISTRO}-cartographer-ros \
#     ros-${ROS_DISTRO}-navigation2 \
#     ros-${ROS_DISTRO}-nav2-bringup \
#     ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
#     ros-${ROS_DISTRO}-ros-gz-bridge
#
# # Install TurtleBot3 Packages
# RUN set -e \
#  && mkdir -p /root/turtlebot3_ws/src \
#  && mkdir -p /root/.gz/fuel/fuel.gazebosim.org \
#  && source /opt/ros/${ROS_DISTRO}/setup.bash \
#  && cd /root/turtlebot3_ws/src \
#  && git clone -b ${ROS_DISTRO} https://github.com/ROBOTIS-GIT/DynamixelSDK.git \
#  && git clone -b ${ROS_DISTRO} https://github.com/ROBOTIS-GIT/turtlebot3_msgs.git \
#  && git clone -b ${ROS_DISTRO} https://github.com/ROBOTIS-GIT/turtlebot3.git \
#  && git clone -b ${ROS_DISTRO} https://github.com/ROBOTIS-GIT/turtlebot3_simulations.git \
#  && rm -rf /var/lib/apt/lists/*
#
# WORKDIR /root/turtlebot3_ws
#
# # Setup Environment (turtlebot3)
# RUN set -e \
#  && source /opt/ros/${ROS_DISTRO}/setup.bash \
#  && rosdep init 2>/dev/null || true \
#  && rosdep update || true \
#  && rosdep install --from-paths /root/turtlebot3_ws/src --ignore-src --rosdistro ${ROS_DISTRO} -y || true \
#  && colcon build --base-paths /root/turtlebot3_ws --symlink-install \
#  && echo "source /root/turtlebot3_ws/install/setup.bash" >> /root/.bashrc \
#  && echo 'source /usr/share/gazebo/setup.sh' >> /root/.bashrc
#
# WORKDIR /root
# # COPY requirements.txt .
#
# ENV TURTLEBOT3_MODEL=waffle
# ENV GAZEBO_MODEL_PATH=/root/turtlebot3_ws/src/turtlebot3_simulations/turtlebot3_gazebo/models
# ENV GZ_MODEL_PATH=/root/turtlebot3_ws/src/turtlebot3_simulations/turtlebot3_gazebo/models
