bash /sync/docker/scripts/docker-flush.sh;
bash /sync/docker/scripts/auto-create-network.sh;
cd /sync/docker/compose;
sudo systemctl restart containerd;
sudo systemctl restart docker;
docker compose -f *.yml up -d;
