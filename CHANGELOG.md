## v0.1.0 (2025-07-31)

### Features

- **deps**: add renovate custom manager for cue helm charts
- nix support (#87)
- **ms**: install metrics-server (#80)
- **headlamp**: add headlamp component (#79)
- **gw**: migrate to real certificates (#76)
- **flux**: github status notifications
- **gw**: make https default, forward http traffic
- **cm**: implement cert-manager (#75)
- implement taskfile (#63)
- add config that can be populated in components (#60)
- **tilt**: metadata for tilt info (#51)
- **dns**: add usable DNS config (#33)
- metrics (#25)
- **postgres**: add operatorator and cluster (#16)
- **tilt**: rewrite tiltfile to remove boilerplate and add flux-mode (#14)

### Bug Fixes

- **ci**: deprecation warning: 'install' is a deprecated alias for 'add' (#120)
- **dns**: fix broken dns upstreaming (#93)
- **metrics**: add privilege to metrics namespace
- **capacitor**: fix and pin capacitor link (#83)
- **headlamp**: watch plugins to make sure sidecar intalled plugins are picked up
- **gw**: add root domain to cert
- **gw**: request wildcard cert for gateway
- **dns**: disable the debug plugin
- **gw**: don't re-use secret name between issuers (#78)
- **cm**: enable ServerSideApply to resolve cert resolution problems (#77)
- **gw**: fix broken entryPoint redirect
- **gw**: fix broken certificate ref
- **lb**: fix broken ipaddresspool reference
- **load-balancer**: allow privileged pod policy in ns (#73)
- move public IPs into existing subnet
- **lb**: avoid taken IPs
- **gateway**: re-enable service monitor (#61)
- **gateway**: fix broken tilt port-forward
- **load-balancer**: fix service being applied outside of a namespace (#55)
- **tilt**: add gateway port-forward (#20)
- **postgres**: manually specify container tag (#17)
- **load-balancer**: fix typo in valuesFrom (#11)
- **gateway**: valuesKeys missing extension (#10)

### Refactors

- adjust external_url to be the root domain (#92)
- **task**: write Tasks for each component to allow for dirty-checking (#86)
- remove unused components (#85)
- **capacitor**: port to holos (#56)
- **dns**: replace post-processor with hand-written role (#47)
- **flux**: move flux-system to root directory (#34)
- **stacks/capacitor**: remove unused network policy
- reimplement stacks to be kustomize and tilt friendly
