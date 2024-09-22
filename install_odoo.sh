#!/bin/bash

# Charger les variables d'environnement
set -a
source .env
set +a

# Mettre à jour le système
sudo apt update -y
sudo apt upgrade -y

# Installer les dépendances nécessaires
sudo apt install -y python3-pip python3-dev build-essential libssl-dev libpq-dev \
libjpeg-dev libjpeg8-dev liblcms2-dev libblas-dev libatlas-base-dev \
postgresql postgresql-contrib

# Créer un utilisateur PostgreSQL
sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';"
sudo -u postgres psql -c "ALTER USER $DB_USER CREATEDB;"

# Installer les bibliothèques Python nécessaires
sudo pip3 install wheel
sudo pip3 install -r https://raw.githubusercontent.com/odoo/odoo/branch-$ODOO_VERSION/requirements.txt

# Cloner le dépôt Odoo
git clone https://github.com/odoo/odoo --depth 1 --branch $ODOO_VERSION --single-branch /opt/odoo

# Créer le répertoire de configuration Odoo
sudo mkdir /etc/odoo
sudo chown $USER:$USER /etc/odoo

# Créer le fichier de configuration d'Odoo
cat <<EOF | sudo tee /etc/odoo/odoo.conf
[options]
; This is the password that allows database operations:
admin_passwd = $ODOO_ADMIN_PASSWORD
db_host = False
db_port = False
db_user = $DB_USER
db_password = $DB_PASSWORD
addons_path = /opt/odoo/addons
logfile = /var/log/odoo/odoo.log
EOF

# Créer le répertoire pour les logs
sudo mkdir /var/log/odoo
sudo chown $USER:$USER /var/log/odoo

# Exécuter Odoo
cd /opt/odoo
./odoo-bin -c /etc/odoo/odoo.conf --xmlrpc-port=$ODOO_PORT &

# Afficher l'adresse d'Odoo
echo "Odoo est maintenant accessible à l'adresse : http://localhost:$ODOO_PORT"