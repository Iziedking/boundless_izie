# **Boundless Prover Node Zero-to-Hero**  

<sup>Ubuntu 20.04 / 22.04 required · updated 24 Jun 2025 · repo by @Iziedking</sup>

---

## Step 1: Overview & Hardware Matrix

| Resource     | Minimum           | Recommended                         |
| ------------ | ----------------- | ----------------------------------- |
| **GPU VRAM** | 8 GB              | ≥ 20 GB (SEG 21) · ≥ 40 GB (SEG 22) |
| **CPU**      | 8 threads @ 3 GHz | 16 threads                          |
| **RAM**      | 32 GiB            | 32–64 GiB                           |
| **Disk**     | 100 GB NVMe       | 250 GB +                            |


#### Cheapest cloud servers (as at Jun 2025)
>[Vast.ai](https://cloud.vast.ai/?ref_id=268438) (4090 24 GB ≈ $0.45/h) see [template](https://cloud.vast.ai/?ref_id=268438)

>[Runpod](https://runpod.io?ref=zpjny9cd) (L40S 48 GB ≈ $0.95/h)

>[Lambda](https://cloud.lambda.ai/instances) (L4 24 GB ≈ $0.60/h)

>You can also see my guide [here](https://x.com/Iziedking/status/1936360991459008909) for a 0$ advantage
---

## Step 2: Install all dependencies
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Iziedking/boundless_izie/main/install_boundless.sh)
```
---

## Step 3: Clone Boundless & Pick Tag
```bash
git clone https://github.com/boundless-xyz/boundless
cd boundless
git checkout release-0.10          
```
---

## Step 4: Prepare .env file
```bash
cp .env.eth-sepolia .env.local      # or .env.base/  .env.base-sepolia
```
Add these to your .env.local
```bash
nano .env.local
```
Paste and input your RPC URL and Private key
```bash
export RPC_URL=http://ip_you_hosted_your_geth-prysm:8545
export PRIVATE_KEY="your_private_key"
SEGMENT_SIZE=21
```
>If the IP you hosted your rpc is 156.78.66.208 change "ip_you_hosted_your_geth-prysm to 156.78.66.208" if your host geth-prysm on same server you are running your broker then it's safe to use http://localhost:8545

Don't have RPC you can self host using geth-Prysm see guide [here](https://github.com/Iziedking/geth-prysm_guide).
Now source you .env.local (each time you open your shell run this before any command)
```bash
source .env.local
```
---

## Step 5: Run a Test Proof

```bash
just bento
```
Open a screen 
```bash
RUST_LOG=info bento_cli -c 32
just bento logs
```
If you see Job Done!, Bento is working
![image](https://github.com/user-attachments/assets/535a21e1-0002-4627-bcf8-74eff9e71078)

---
## Step 6: GPU Tune (SEGMENT_SIZE & compose.yml)
| VRAM    | SEGMENT\_SIZE |
| ------- | ------------- |
| 8 GB    | 19            |
| 16 GB   | 20            |
| 20 GB   | 21            |
| ≥ 40 GB | 22            |

>Set SEGMENT_SIZE in step 4 According to your VRAM

patch compose.yml
```bash
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
```
Remove extra ```gpu_prove_agentX``` blocks if you have only one GPU or just comment it out incase you later add more gpu.

---
## Step 6: Install Boundless CLI & Deposit Stake

```bash
cargo install --locked boundless-cli
```
Based on your networl(Sepolia, Base Sepolia or Base Mainnet) source your env file
```bash
source .env.local
```
Deposit your stake, you can change default amount to what you have see [Deployment](https://docs.beboundless.xyz/developers/smart-contracts/deployments) page for faucet links and more info
```bash
boundless account deposit-stake 100 --tx-timeout 120
```
---
## Step 7: Start Broker
```bash
just broker
just broker logs
```
### To stop:
```bash
just broker down
```
### To clean all data
```bash
just broker clean
```
---
### *Let's say you added two more GPU to your main GPU here is how to adjust compose.yml accordingly*
first check if your GPUs are recognized 
```bash
nvidia-smi -L
```
you will get something likw this:
``
GPU 0: NVIDIA GeForce RTX 3090 (UUID: GPU-abcde123-4567-8901-2345-abcdef678901)
GPU 1: NVIDIA GeForce RTX 3090 (UUID: GPU-fedcb987-6543-2109-8765-abcdef123456)
``
then add rhese to compose.yml
```bash
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
gpu_prove_agent1:
  mem_limit: 6G
  cpus: 4
  runtime: nvidia
  deploy:
    resources:
      reservations:
        devices:
          - driver: nvidia
            device_ids: ['1']
            capabilities: [gpu]
```
> Don't forget Ctrl + O then hit enter to save nano files, then Ctrl + X to exit nano

---

## Ste 8: Optimizing your broker performance for maximum result
#### 1. Set a Benchmark
```bash
source .env.local
```

Pick ann order ID from [explorer](https://explorer.beboundless.xyz/orders)

<img width="451" alt="Screenshot 2025-06-25 130155" src="https://github.com/user-attachments/assets/6b47b09f-714e-4ccd-ad35-01bdbf7b3b02" />                                                         



```bash
ORDER=order_ID
boundless proving benchmark --request-ids $ORDER --rpc-url $RPC_URL
```
You will see something like ``peak_prove_khz = 680 kHz``

Then go to your broker.toml file, take ~80% of the worst-case kHz and set peak_prove_kHz in this case it would be 564
```bash
nano broker.toml
```
Find peak_prove_kHz abd replace with 564 e.g
``peak_prove_kHz = 564``

### 2. Broker Knobs
In broker.toml find the following and edit to your test for me I will recommend this:
```
mcycle_price        = "0.0000002"   # 0.2 gwei/Mcycle
lockin_priority_gas = 8000000000    # 8 gwei (≈25 gwei on Base)
max_concurrent_proofs = 2
min_deadline        = 240
txn_timeout         = 45
```
```bash
docker compose restart broker
```

This is a much streamlined process you can See [Official Docs](https://docs.beboundless.xyz/provers/quick-start) for more informations

## **Bonus Tips**

Claim Dev and Prover role with one click
Fund your wallet used for this node with 0.0001 base eth and 0.2 base usdcand run this command
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Iziedking/boundless_izie/main/stake.sh)
```
Go to [Guild](https://guild.xyz/boundless-xyz) add this wallet to your guild profile refresh and claim roles. Join boundless [discord community](https://discord.gg/aXRuD6spez) and be active
GoodLuck!
