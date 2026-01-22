cd /docker-storage

rm -r traefik/certs/*
cp -rL certbot/letsencrypt/live/* traefik/certs/

echo "Copied!"
