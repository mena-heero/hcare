#!/bin/bash

# install Docker
sudo sh install-docker.sh

# Export apps.json
export APPS_JSON_BASE64=$(base64 -w 0 apps.json)

# Up Traefik
docker compose --project-name traefik \
  --env-file gitops/traefik.env \
  -f overrides/compose.traefik.yaml \
  -f overrides/compose.traefik-ssl.yaml up -d

# Up MariaDB
docker compose --project-name mariadb --env-file gitops/mariadb.env -f overrides/compose.mariadb-shared.yaml up -d


# Creat New Docker COmpose
docker compose \
  --project-name hcare \
  --env-file gitops/hcare.env \
  -f compose.yaml \
  -f overrides/compose.redis.yaml \
  -f overrides/compose.multi-bench.yaml \
  -f overrides/compose.multi-bench-ssl.yaml \
  config > gitops/hcare.yaml



# Deploy hcare containers:

docker compose --project-name hcare -f gitops/hcare.yaml up -d


# New Site 

docker compose --project-name erpnext-one exec backend \
bench new-site api.alltargeting.com --no-mariadb-socket --mariadb-root-password superh2soc --install-app heero alltarget --admin-password superh2soc
# gitops and run Project
docker system prune -af --volumes