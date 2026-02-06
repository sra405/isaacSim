## Isaac Sim

An initial PoC for Isaac Sim. This repository contains a simple setup to demonstrate the requirements, installation steps, and basic usage of Isaac Sim.

## Usage

Pull, set the `CF_TUNNEL_TOKEN` in a `.env` file and run the compose file:

```bash
docker compose up -d
```

Key commands:
- `./isaac-sim.compatibility_check.sh` - determines hardware and OS compatibility
- `./runheadless.sh -v` - runs Isaac Sim in headless mode

for enabling remote access when running headless:
- `PUBLIC_IP=$(curl -s ifconfig.me) && ./runheadless.sh --/app/livestream/publicEndpointAddress=$PUBLIC_IP --/app/livestream/port=49100` - or set the PUBLIC_IP variable manually

the docs state:
```
The following ports must be opened on the host running Isaac Sim:

UDP port 47998
TCP port 49100
```
*this is essential, without 47998 the handshake will fail and livestreaming will not work over 49100*

I suspect these can be mapped through cloudflare tunnel too but have not yet tested as my local hardware is not compatible with Isaac Sim.

## Deployment methods

- Locally
  - [headless](https://docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/install_container.html#isaac-sim-setup-remote-headless-container) using docker ([container registry](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/isaac-sim?version=5.1.0))
  - from source ([Github](https://github.com/isaac-sim/IsaacSim?tab=readme-ov-file#quick-start))
- Cloud
  - Brev - one click NVIDIA instances ([docs](https://docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/install_advanced_cloud_setup_brev.html))


## Notes

This is a work in progress repo with the aim of committing a minimal working example of Isaac Sim usage. With the proposed approach being to spin up/down cloud GPU compute instances its vital to version control the setup steps as much as possible.

Key files:
- [compose.yml](compose.yml) - a compose file produced from the manual docker run commands in the installation steps documented [here](https://docs.isaacsim.omniverse.nvidia.com/5.1.0/installation/install_advanced_cloud_setup_brev.html#running-isaac-sim-container).

Key services:
- `isaac-sim` - the main Isaac Sim container
- `cloudflared` - a Cloudflare tunnel container to expose SSH access to Isaac Sim for remote control
- `openssh-server` - an SSH server container to allow remote access into Isaac Sim via the cloudflared tunnel

### Brev

With the `isaac-sim` container running, I can connect to the instance via Brev CLI and exec into the container to run the headless command. The ports need to be opened for livestreaming but it works.

Manually I need to run the following command to change ownership of the mounted volumes to allow Isaac Sim to write to them:

```bash
sudo chown 777 -R ~/docker/isaac-sim/
```

Asset loading currently fails with red boxes in the file explorer and the following error in the logs when clicked:

```bash
Failed to find item at 'https://omniverse-content-production.s3-us-west-2.amazonaws.com/'
```

### ROS

I'm currently unsure in doosan-robot works with Isaac Sim (see closed Github issue [here](https://github.com/DoosanRobotics/doosan-robot2/issues/83)). If it does, I will add a ROS container to the compose file and update the usage instructions accordingly.

### Questions

- Can I get this all loading in Brev on startup?
- Can I get assets loaded?
- Can I 

### Local Windows Attempt

This attempt at least confirmed the setup in the docker compose file works. On running the compatibility check (inside the docker image) it returned the following:

```bash
[10.194s] =============================================
[10.195s] 
[10.197s] NVIDIA GPU(s)
[10.466s]   |-- Driver version [supported]
[10.466s]   |     |-- installed: 582.28
[10.467s]   |     |-- minimum: 535.161
[10.601s]   |-- GPU 0 [unsupported]
[10.602s]   |     |-- name: NVIDIA GeForce GTX 1070
[10.727s]   |-- GPU 0: VRAM [not enough]
[10.727s]   |     |-- total: 8.59 GB
[10.727s]   |     |-- minimum: 10 GB
[10.728s] 
[10.729s] CPU, RAM and Storage
[10.730s]   |-- CPU processor [supported]
[10.731s]   |     |-- name: Intel(R) Core(TM) i7-3770 CPU @ 3.40GHz
[10.732s]   |-- CPU cores [good]
[10.733s]   |     |-- total: 8
[10.734s]   |     |-- minimum: 4
[10.735s]   |-- CPU power governor [CPU power governor file not found for some cores]
[10.735s]   |     |-- governor(s): 
[10.736s]   |-- RAM [not enough]
[10.737s]   |     |-- total: 8.27 GB
[10.738s]   |     |-- minimum: 32 GB
[10.758s]   |-- Storage [excellent]
[10.758s]   |     |-- total available: 2709.5 GB
[10.759s]   |     |-- minimum: 50 GB
[10.762s] 
[10.762s] Others
[10.764s]   |-- Operating system [supported]
[10.765s]   |     |-- name and version: Ubuntu 24.04.2 LTS
[10.767s]   |-- Display [no display was detected, visit the following link for information on the different livestreaming methods to view headless application instances: docs.omniverse.nvidia.com/isaacsim/latest/installation/manual_livestream_clients.html]
[10.768s] 
[10.769s] =============================================
[10.770s] 
[10.771s] System checking result: FAILED
[10.772s] 
[10.773s] =============================================
```

This confirms the following minimum requirements:

|Component|Your System (Detected)|Isaac Sim 5.1.0 Minimum|Status|
| ------- | -------------------- | --------------------- | ---- |
GPU Model|NVIDIA GeForce GTX 1070 (Pascal)|RTX 3070 (Turing+)|❌ Unsupported
VRAM|8.59 GB|10 GB - 16 GB|❌ Not Enough
System RAM|8.27 GB|32 GB|❌ Critical Fail
CPU|i7-3770 (4 Cores / 8 Threads)|i7 (7th Gen) / 4+ Cores|✅ Supported
Driver Version|582.28|535.161+|✅ Excellent
Storage|2.7 TB available|50 GB SSD|✅ Excellent
OS|Ubuntu 24.04.2 (WSL2)|Ubuntu 22.04+ / Windows 10+|✅ Supported