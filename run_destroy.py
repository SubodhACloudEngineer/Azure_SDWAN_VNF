#!/usr/bin/env python3
import subprocess
import time
import sys

def run_command(cmd, cwd=None, delay_after=2):
    """Run shell command with live output and optional delay."""
    print(f"\n{'='*80}\n> Running: {cmd}\n{'='*80}\n", flush=True)
    process = subprocess.Popen(
        cmd, cwd=cwd, shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True
    )
    for line in process.stdout:
        sys.stdout.write(line)
        sys.stdout.flush()
    process.wait()
    print(f"\n[Exit code: {process.returncode}]")
    time.sleep(delay_after)
    return process.returncode

def main():
    terraform_dir = "/mnt/c/Users/subodh.kashyap/Azure_SDWAN_VNF"
    ansible_dir = f"{terraform_dir}/ansible-sdwan"

    print("\n🚀 Starting automated SD-WAN Delete pipeline...\n")
    time.sleep(1)

    # Step 1: Terraform Destroy
    run_command("terraform destroy --auto-approve", cwd=terraform_dir, delay_after=5)

    print("\n✅ Destroy complete! All infrastructure Decommissioned.\n")

if __name__ == "__main__":
    main()
