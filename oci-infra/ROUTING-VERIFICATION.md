# OCI Hub-Spoke Routing Verification

## Current Topology

```
Internet
    ↓
┌─────────────────┐
│   DMZ VCN       │ (10.10.0.0/16)
│  - IGW enabled  │
│  - Bastion VM   │ (public subnet/public IP)
└────────┬────────┘
         │
    ┌────┴────┐ DRG (Hub)
    │         │
 ┌──┴─────────┐
 │ Spoke-A    │ (10.20.0.0/16)
 │ - 1 VM     │ (private subnet/no public IP)
 └────────────┘
```

## Routing Rules Logic

### DMZ Subnet Routes:
- ✅ 0.0.0.0/0 → Internet Gateway (internet edge)
- ✅ 10.20.0.0/16 → DRG (to Spoke-A)

### Spoke-A Subnet Routes:
- ✅ 10.10.0.0/16 → DRG (to DMZ)
- ✅ 0.0.0.0/0 → DRG (transit to DMZ internet edge)

## Code Verification

Spoke private subnet default route to DRG in `main.tf`:

```terraform
dynamic "route_rules" {
  for_each = local.vcns_resolved[each.value.vcn_key].role == "spoke" && each.value.internet_access && !each.value.assign_public_ip_on_vnic ? [1] : []
  content {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = module.drg_hub.drg_id
  }
}
```

## Test After Deployment

```bash
# 1. Verify route tables in OCI console
# - dmz-management: 0.0.0.0/0 -> IGW and 10.20.0.0/16 -> DRG
# - spoke-a-workload: 10.10.0.0/16 -> DRG and 0.0.0.0/0 -> DRG

# 2. SSH from your machine to bastion (DMZ public IP)
ssh -i ~/.ssh/id_rsa opc@<bastion-public-ip>

# 3. From bastion, SSH to private spoke VM
ssh -i ~/.ssh/id_rsa opc@<spoke-a-private-ip>

# 4. From spoke-a VM, verify outbound internet
curl -I https://example.com
```

## Expected Behavior

✅ **Allowed:**
- Spoke-A ↔ DMZ private connectivity through DRG
- Spoke-A default egress is forced through DRG toward DMZ edge
- SSH inbound to Spoke-A only from DMZ CIDR (bastion path)
- SSH inbound from internet to bastion only (TCP/22)

⚠️ **Important:**
- Keep spoke VM without public IP to enforce bastion-only administration.
- Hub-spoke DRG is used for inter-VCN private routing and for spoke default-route transit to DMZ.
- This design enforces the path `spoke private subnet -> DRG -> DMZ -> IGW` (no NAT gateway resource).

## Conclusion

This simplified test layout provides:
- One spoke workload VM for validation
- DRG-centric inter-VCN routing
- Bastion-only access to private spoke VM
- No-NAT hub-spoke transit routing through DRG/DMZ
