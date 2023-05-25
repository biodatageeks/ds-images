```bash
docker build -t  biodatageeks/ds-hub:3.0.0-0.dev.git.6145.h879d2e0e-2 \
--build-arg BASE_IMAGE=jupyterhub/k8s-hub:3.0.0-0.dev.git.6145.h879d2e0e .
docker push docker.io/biodatageeks/ds-hub:3.0.0-0.dev.git.6145.h879d2e0e-2
```