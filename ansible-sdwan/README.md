# Ansible SD-WAN Edge (StrongSwan + FRR)

This pack configures Ubuntu-based Azure VMs as simulated SD-WAN edges:
- StrongSwan (IPSec) for encrypted site-to-site tunnels
- FRR (BGP) for dynamic routing over the tunnel

## 1) Prereqs
- Python + Ansible on your workstation (`pip install ansible`)
- Reachable public IPs for both VMs (Terraform outputs)
- Azure NSG on WAN allows UDP/500 and UDP/4500 plus TCP/22

## 2) Fill inventory & vars
Edit `inventory/hosts.yml` with each VM's public IP.
Edit `host_vars/site-east.yml` and `host_vars/site-west.yml`:
- Set `peer_ip`, `local_lan_cidr`, `peer_lan_cidr`, and `ipsec_psk`.

## 3) Dry run / reachability
ansible -i inventory/hosts.yml sdwan_edges -m ping

## 4) Run
ansible-playbook -i inventory/hosts.yml site.yml

## 5) Validate
# IPSec
ssh azureuser@<east-ip> "sudo ipsec statusall | sed -n '1,60p'"
ssh azureuser@<west-ip> "sudo ipsec statusall | sed -n '1,60p'"
# BGP
ssh azureuser@<east-ip> "sudo vtysh -c 'show bgp summary'"
ssh azureuser@<west-ip> "sudo vtysh -c 'show bgp summary'"

## 6) Notes
- Use Ansible Vault for `ipsec_psk` in production.
- If vtysh permission denied, reconnect after play (user added to group), or run with sudo.
