cd /docker-storage

rm -r nginx/certs/*
cp -rL certbot/letsencrypt/live/* nginx/certs/

echo "Copied!"
