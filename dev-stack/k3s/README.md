# Local Kubernetes with K3s

The Compose file starts a single-node K3s cluster in a privileged container. Start it with:

```bash
docker compose -f compose.yaml up -d --wait
```

The Kubernetes API is exposed at `https://localhost:16443`; local ingress uses ports `18080` and `18443`. Copy the generated kubeconfig and update its API address before using it from the host:

```bash
docker exec k3s-server kubectl get nodes
mkdir -p ~/.kube
docker cp k3s-server:/output/kubeconfig.yaml ~/.kube/k3s.yaml
sed -i 's/127.0.0.1:6443/127.0.0.1:16443/' ~/.kube/k3s.yaml
kubectl --kubeconfig ~/.kube/k3s.yaml get nodes
```

The first command works without a host `kubectl` installation. The remaining commands use the host `kubectl` client.

Stop the cluster and remove its container with:

```bash
docker compose -f compose.yaml down
```

The default shutdown keeps the K3s cluster data volume. Add `--volumes` only when you intend to delete that cluster state. Kubernetes workloads do not join the other Compose networks automatically; expose or configure access to those services explicitly.
