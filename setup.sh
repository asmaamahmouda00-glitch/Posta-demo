#!/bin/bash
set -e

echo "==> Updating system..."
apt update -y && apt upgrade -y

echo "==> Installing nginx and git..."
apt install -y nginx git

echo "==> Cloning Posta-demo..."
rm -rf /var/www/posta-demo
git clone https://github.com/asmaamahmouda00-glitch/Posta-demo /var/www/posta-demo

echo "==> Setting permissions..."
chown -R www-data:www-data /var/www/posta-demo
chmod -R 755 /var/www/posta-demo

echo "==> Configuring nginx..."
cat > /etc/nginx/sites-available/posta-demo << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/posta-demo;
    index index.html;

    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

ln -sf /etc/nginx/sites-available/posta-demo /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

echo "==> Testing nginx config..."
nginx -t

echo "==> Starting nginx..."
systemctl restart nginx
systemctl enable nginx

echo "==> Configuring firewall..."
ufw allow 22/tcp
ufw allow 80/tcp
ufw --force enable

echo ""
echo "Done! Visit http://37.61.219.166/"
