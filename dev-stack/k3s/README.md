# Local Kubernetes with K3s

This optional Compose file starts a single-node K3s cluster in a privileged container. It does not install a Kubernetes service on the host. Docker must be allowed to run privileged containers.

From this directory, start the cluster and wait for the API server healthcheck:

```bash
docker compose -f compose.yaml up -d --wait
```

The Kubernetes API is exposed at `https://127.0.0.1:16443`; the bundled Traefik ingress uses host ports `18080` and `18443`.

Check the node without installing `kubectl` on the host:

```bash
docker exec k3s-server kubectl get nodes
```

To use a host `kubectl` client, copy the generated kubeconfig and update its API address:

```bash
mkdir -p ~/.kube
docker cp k3s-server:/output/kubeconfig.yaml ~/.kube/k3s.yaml
sed -i 's/127.0.0.1:6443/127.0.0.1:16443/' ~/.kube/k3s.yaml
kubectl --kubeconfig ~/.kube/k3s.yaml get nodes
```

The `kubectl` client on the host is a separate prerequisite; the Compose stack does not install it.

Stop the cluster and remove its container with:

```bash
docker compose -f compose.yaml down
```

The default shutdown keeps the K3s cluster data volume. Add `--volumes` only when you intend to delete that cluster state. Kubernetes workloads do not join the other Compose networks automatically; expose or configure access to those services explicitly.
