# Quick Start

Build locally:

```bash
ansible-galaxy collection build . --output-path dist
ansible-galaxy collection install -p ./.ansible/collections dist/crownops-deploy_services-0.1.0.tar.gz --force
```

Consuming repos should install this collection from GitHub via `ansible-galaxy collection install`.
