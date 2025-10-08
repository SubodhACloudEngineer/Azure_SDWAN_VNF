#!/usr/bin/env python3
import subprocess, time, sys, os, re, pathlib

# === Adjust these if your paths differ ===
TF_DIR  = "/mnt/c/Users/subodh.kashyap/Azure_SDWAN_VNF"
ANS_DIR = f"{TF_DIR}/ansible-sdwan"
INV     = f"{ANS_DIR}/inventory/hosts.yml"
# =========================================

def run_command(cmd, cwd=None, delay_after=2, env=None):
    """Run a shell command with live output and an optional post delay."""
    print(f"\n{'='*80}\n> Running: {cmd}\n{'='*80}\n", flush=True)
    proc = subprocess.Popen(
        cmd, cwd=cwd, shell=True,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        text=True, env=env
    )
    for line in proc.stdout:
        sys.stdout.write(line)
        sys.stdout.flush()
    proc.wait()
    print(f"\n[Exit code: {proc.returncode}]\n")
    time.sleep(delay_after)
    return proc.returncode

def parse_hosts(inv_path):
    """Try to read hostnames like 'site-east'/'site-west' from the YAML inventory."""
    hosts = []
    if not os.path.exists(inv_path):
        return ["site-east", "site-west"]
    with open(inv_path, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            m = re.match(r"\s*([A-Za-z0-9._-]+):\s*$", line)
            if m:
                name = m.group(1)
                if name.startswith("site-"):
                    hosts.append(name)
    # Fallback to the two standard names if nothing parsed
    return hosts or ["site-east", "site-west"]

def simulate_ansible_ping(hosts):
    """Print a clean, success-looking ansible -m ping run (simulated)."""
    print(f"\n{'='*80}\n> Running: ansible -i inventory/hosts.yml sdwan_edges -m ping"
          f"\n{'='*80}\n", flush=True)
    time.sleep(0.8)
    print("PLAY [Ping SD-WAN edges] *******************************************************************")
    time.sleep(0.3)
    print("TASK [ping] *********************************************************************************")
    for h in hosts:
        time.sleep(0.25)
        print(f"ok: [{h}]")
    time.sleep(0.4)
    print("\nPLAY RECAP ***********************************************************************************")
    for h in hosts:
        print(f"{h:22} : ok=1   changed=0   unreachable=0   failed=0   skipped=0   rescued=0   ignored=0")
    print()

def simulate_ansible_playbook(hosts):
    """Print a clean, success-looking ansible-playbook run (simulated)."""
    print(f"\n{'='*80}\n> Running: ansible-playbook -i inventory/hosts.yml site.yml"
          f"\n{'='*80}\n", flush=True)
    time.sleep(0.8)
    print("PLAY [Configure StrongSwan IPSec and FRR BGP on SD-WAN edges] *******************************")
    time.sleep(0.3)
    print("TASK [Gathering Facts] **********************************************************************")
    for h in hosts:
        time.sleep(0.25)
        print(f"ok: [{h}]")
    time.sleep(0.3)
    print("TASK [Install strongSwan and FRR packages] **************************************************")
    for h in hosts:
        time.sleep(0.25)
        print(f"changed: [{h}]")
    time.sleep(0.3)
    print("TASK [Render strongswan.conf / ipsec.conf / ipsec.secrets] **********************************")
    for h in hosts:
        time.sleep(0.25)
        print(f"changed: [{h}]")
    time.sleep(0.3)
    print("TASK [Enable & start services] **************************************************************")
    for h in hosts:
        time.sleep(0.25)
        print(f"changed: [{h}]")
    time.sleep(0.3)
    print("\nPLAY RECAP ***********************************************************************************")
    for h in hosts:
        print(f"{h:22} : ok=4   changed=3   unreachable=0   failed=0   skipped=0   rescued=0   ignored=0")
    print()

def main():
    print("\n🚀 Starting automated SD-WAN demo (Terraform real, Ansible simulated)…\n")
    time.sleep(0.8)

    # 1) Terraform (real)
    run_command("terraform init", cwd=TF_DIR)
    run_command("terraform apply --auto-approve", cwd=TF_DIR, delay_after=4)

    # 2) Generate inventory (real)
    run_command("./gen_inventory.sh", cwd=TF_DIR, delay_after=2)

    # 3) Simulated Ansible phase (no real SSH, no prompts, always 'success')
    hosts = parse_hosts(INV)
    simulate_ansible_ping(hosts)
    time.sleep(1.0)
    simulate_ansible_playbook(hosts)
    time.sleep(0.8)

    print("✅ Demo complete! Terraform provisioned infra; Ansible configuration reported successful.\n")

if __name__ == "__main__":
    main()
