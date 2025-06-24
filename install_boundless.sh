#!/usr/bin/env bash
# Boundless bootstrap – v2025-06-24
set -euo pipefail

DRIVER_VERSION=${1:-535}      # pass --driver 550 to use 550 series

echo "==> Updating apt & core packages"
sudo apt update -y
sudo apt upgrade -y

echo "==> Installing helpers"
sudo apt install -y \
  curl git build-essential tmux jq htop nvtop moreutils ufw

echo "==> Installing Docker Engine"
curl -fsSL https://get.docker.com | sudo bash
sudo usermod -aG docker "$USER"

echo "==> Enabling basic UFW rules"
sudo ufw allow OpenSSH
sudo ufw allow 80,443,3000,8081/tcp
sudo ufw --force enable

echo "==> Enabling basic UFW rules"
sudo ufw allow OpenSSH               # 22
sudo ufw allow 80,443/tcp            # HTTP / HTTPS
sudo ufw allow 3000,8080,8081/tcp    # Grafana + local web apps + Boundless REST
sudo ufw allow 8545/tcp              # JSON-RPC (Geth / Prysm)
sudo ufw allow 4000,3500/tcp         # Beacon / execution gossip, custom jobs
sudo ufw allow 9000/tcp              # Minio console
sudo ufw --force enable

echo "==> Installing NVIDIA driver & container runtime"
if [[ "$DRIVER_VERSION" != "skip" ]]; then
  sudo apt install -y nvidia-driver-"$DRIVER_VERSION"
fi
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | \
  sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/"$distribution"/nvidia-container-toolkit.list | \
  sed 's#deb #deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit.gpg] #' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt update && sudo apt install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

echo "==> Installing Rust / rzup"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
curl -L https://risczero.com/install | bash
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc

echo "==> Installing Foundry (cast/forge)"
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc

echo "==> Done. Reboot recommended now!"
