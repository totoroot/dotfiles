# pi-vm

Tier 4 VM isolation for Pi using Lima.

## Commands

```sh
pi-vm init       # create VM from config/lima/pi-vm.yaml
pi-vm start      # start VM
pi-vm shell      # open shell in VM
pi-vm            # run pi inside VM
pi-vm --help     # forwarded to pi inside VM
pi-vm stop       # stop VM
pi-vm delete     # delete VM
pi-vm recreate   # destroy and recreate VM
```

## Security model

- no host mounts (`mounts: []`)
- repo should be cloned inside the VM
- VM egress restricted to:
  - DNS (53)
  - HTTPS (443)
- API keys are forwarded only for the current `pi-vm` invocation

## Notes

- Run `pi-vm shell` and clone repos inside the VM.
- `pi-vm` uses the Lima instance name `pi-sandbox` by default.
- Override with `PI_VM_NAME` or `PI_VM_CONFIG` if needed.
