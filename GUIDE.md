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
nano .env.local
```
Add these to your .env.local
```bash
nano .env.local
```
Paste and input your RPC URL and Private key
```bash
export RPC_URL="your_private_key"
export PRIVATE_KEY="0x…"
```
Don't have RPC you can self host using geth-Prysm see guide [here](https://github.com/Iziedking/geth-prysm_guide).
Now source you .env.local (each time you open your shell run this before any command)
```bash
source .env.local
```
  




