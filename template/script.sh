echo === Starting ====
sleep 2

echo ===           1. Installing curl===
sudo apt-get install -y curl
sleep 2

echo ===           2. Installing Node 20===
sleep 4
curl -fsSL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh

sudo -E bash nodesource_setup.sh
sleep 2

sudo apt-get install -y nodejs
sleep 5

echo ================
echo ===   Node version installed is $(node -v)   ===
echo ===   npm version installed is $(npm -v)   ===
echo ===   My private IP address is $(hostname -I)   ===
echo ===   My public IP address is $(curl -s http://whatismyip.akamai.com/)===
sleep 2



echo ===          3. Installing Nginx   ===
sleep 3
sudo apt update
sudo apt install -y nginx

sleep 2
sudo systemctl enable nginx
sudo systemctl restart nginx

cat << EOF >> hello.js
const http = require('http');
const hostname = 'localhost';
const port = 3000;
const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Actividad 1 en Node con reverse proxy usando Nginx!\n');
});
server.listen(port, hostname, () => {
  console.log('server running on port 3000');
});
EOF


echo ===     4. Installing PM2   ===
sleep 2
sudo npm install pm2@latest -g
pm2 start hello.js
sleep 2

curl http://localhost:3000

pm2 startup system
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
pm2 save
sudo systemctl status pm2-ubuntu
ps aux | grep pm2 | grep -v grep | awk '{print $2}' | xargs kill -9
sudo systemctl start pm2-ubuntu


echo ===    5. Setting up Nginx  ===


sudo cat << EOF >> default
# Default server configuration
#
server {
        listen 80;
        server_name localhost;

        location / {
                proxy_pass http://localhost:3000;
                proxy_http_version 1.1;
                proxy_set_header Upgrade \$http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host \$host;
                proxy_cache_bypass \$http_upgrade;

        }

}

EOF

sudo cp default /etc/nginx/sites-available/default
sleep 2

sudo nginx -t
sudo systemctl restart nginx


