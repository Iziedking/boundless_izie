Boundless Prover – Zero‑to‑Hero Guide

Updated 24 Jun 2025 · works on Ubuntu 20.04 & 22.04

Table of Contents

Overview & Hardware Matrix

One‑shot Bootstrap Script

Clone Boundless & Pick Tag

Prepare Network env

GPU Tune — SEGMENT_SIZE & compose.yml

Start Stack & Benchmark

Broker Knobs that Matter

Stake USDC + ETH (Guild Roles)

Monitoring, Common Commands

Network Switch, Upgrade, Stop

Common Errors ➜ Fixes

Appendix A — Manual Install (air‑gapped)

Appendix B — Hardware ⇆ Settings Quick Ref



1 • Overview & Hardware Matrix

Resource

Minimum

Recommended

GPU VRAM

8 GB

≥ 20 GB (SEG=21) │ ≥ 40 GB (SEG=22)

CPU

8 threads @ 3 GHz

16 threads

RAM

32 GiB

32–64 GiB

Disk

100 GB NVMe

250 GB +

Cheapest reliable spots (Jun 2025): Vast.ai (RTX 4090 $0.45 / h), Runpod‑Community (L40S 48 GB $0.95 / h), Lambda (L4 24 GB $0.60 / h).



2 • One‑shot Bootstrap Script

curl -fsSL https://raw.githubusercontent.com/your‑gist/boundless‑bootstrap/main/install_boundless.sh | \
  sudo bash -s -- --driver 535   # change to 550 if Ubuntu 24.04

What the script installs

Docker + docker‑compose

NVIDIA driver & nvidia‑container‑toolkit

UFW (opens 22,80,443,3000,8081)

Rust + Risc Zero rzup + cargo‑risczero

Foundry (forge / cast)

Helper utils (tmux, jq, nvtop, moreutils)

If Secure‑Boot fails NVIDIA: rerun with --driver skip and install driver via cloud UI.



3 • Clone Boundless & Checkout

git clone https://github.com/boundless-xyz/boundless && cd boundless
git checkout release-0.10   # latest stable tag



4 • Prepare Network env

cp .env.eth-sepolia .env.local        # or .env.base, .env.base-sepolia
nano .env.local

Add only two lines:

export RPC_URL="https://<provider>/<project>"
export PRIVATE_KEY="0x…"

Load it whenever you open a shell:

source .env.local



5 • GPU Tune — SEGMENT_SIZE & compose

VRAM

SEGMENT_SIZE

 8 GB

 19

 16 GB

 20

 20 GB

 21

 40 GB+

 22

Put in .env.local:

SEGMENT_SIZE=21

compose.yml tweaks (single‑GPU):

x-exec-agent-common:
  mem_limit: 4G
  cpus: 3
  entrypoint: /app/agent -t exec --segment-po2 ${SEGMENT_SIZE}

gpu_prove_agent0:
  mem_limit: 6G
  cpus: 4
  runtime: nvidia
  deploy:
    resources:
      reservations:
        devices:
          - driver: nvidia
            device_ids: ['0']
            capabilities: [gpu]

Remove extra agent sections if you have only one card.



6 • Start Stack & Benchmark

just broker              # boots Bento + Broker

# choose a fresh order ID from explorer (same network)
ORDER=0xc2db89b2bd34ceac6c74fbc0b2ad3a280e66db07bb8c8ec

boundless proving benchmark --request-ids $ORDER --rpc-url $RPC_URL

If worst‑case shows 600 kHz → set 480 kHz in broker.toml.

peak_prove_khz = 480



7 • Broker Knobs

mcycle_price        = "0.0000003"    # 0.3 gwei/Mcycle
lockin_priority_gas = 5000000000      # 5 gwei  (25 gwei on Base main‑net)
max_concurrent_proofs = 2             # raise to 3 when GPU <80 % util
min_deadline = 240                    # seconds
txn_timeout = 45                      # extend on slow RPCs

Apply:

docker compose restart broker



8 • Stake USDC & ETH for Guild Roles (Base main‑net)

8.1 Auto‑script stake.sh

#!/usr/bin/env bash
set -euo pipefail
USDC=0x833589FCD6eDb6E08f4c7C32D4f71B54bdA02913
MARKET=0x26759dBb201aFbA361Bec78E097Aa3942B0b4AB8
RPC=https://mainnet.base.org
PK=${PRIVATE_KEY:?export PRIVATE_KEY first}
USDC_AMT=100000        # 0.1 USDC (6 dec)
ETH_WEI=10000000000000000  # 0.01 ETH

echo "Approving 0.1 USDC…"
cast send $USDC "approve(address,uint256)" $MARKET $USDC_AMT --pk $PK --rpc $RPC --type 2 --gas-price 25gwei

echo "Depositing USDC stake…"
cast send $MARKET "depositStake(uint256)" $USDC_AMT --pk $PK --rpc $RPC --type 2 --gas-price 25gwei

echo "Staking 0.01 ETH…"
cast send $MARKET "stake()" --value $ETH_WEI --pk $PK --rpc $RPC --type 2 --gas-price 25gwei

echo "✓ Done. Refresh Guild.xyz to claim roles"

Run:

chmod +x stake.sh && ./stake.sh

8.2 Manual cast commands

AMT=100000   # 0.1 USDC
USDC=0x833589FCD6eDb6E08f4c7C32D4f71B54bdA02913
MARKET=0x26759dBb201aFbA361Bec78E097Aa3942B0b4AB8
PK=0x…
RPC=https://mainnet.base.org

cast send $USDC "approve(address,uint256)" $MARKET $AMT --pk $PK --rpc $RPC
cast send $MARKET "depositStake(uint256)" $AMT --pk $PK --rpc $RPC
cast send $MARKET "stake()" --value 10000000000000000 --pk $PK --rpc $RPC

TroubleshootTRANSFER_FROM_FAILED → Wrong raw amount or no USDC balance.Error estimating gas → add --type 2 --gas-price 25gwei.
