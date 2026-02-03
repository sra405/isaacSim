## Isaac Sim

An initial PoC for Isaac Sim. This repository contains a simple setup to demonstrate the requirements, installation steps, and basic usage of Isaac Sim.

## Notes

This is a work in progress repo with the aim of committing a minimal working example of Isaac Sim usage. With the proposed approach being to spin up/down cloud GPU compute instances its vital to version control the setup steps as much as possible.

Key files:
- [compose.yml](compose.yml) - a compose file produced from the manual docker run commands in the installation steps documented [here](https://docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/install_advanced_cloud_setup_brev.html#running-isaac-sim-container).

## Deployment methods

- Locally
  - [headless](https://docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/install_container.html#isaac-sim-setup-remote-headless-container) using docker ([container registry](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/isaac-sim?version=5.1.0))
  - from source ([Github](https://github.com/isaac-sim/IsaacSim?tab=readme-ov-file#quick-start))
- Cloud
  - Brev - one click NVIDIA instances ([docs](https://docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/install_advanced_cloud_setup_brev.html))
