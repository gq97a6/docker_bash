bash /sync/docker/scripts/docker-flush.sh;
bash /sync/docker/scripts/auto-create-network.sh;
cd /sync/docker/compose;
sudo systemctl restart containerd;
sudo systemctl restart docker;

for f in *.yml; do docker compose -f $f up -d; done;
