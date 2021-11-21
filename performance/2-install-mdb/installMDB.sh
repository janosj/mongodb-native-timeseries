# Install MDB standalone
# Use to import existing MDB deployment into Ops Manager.
# https://docs.mongodb.com/v5.0/tutorial/install-mongodb-enterprise-on-red-hat/

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

echo "Setting timezone to US East Coast..."
timedatectl set-timezone America/New_York

# ulimit settings
# https://docs.mongodb.com/v4.4/reference/ulimit/
echo Increasing system limits for mongod user...
cp limits.conf /etc/security

# configure yum repo
echo
echo Configuring Yum repo....
echo "[mongodb-enterprise-5.0]
name=MongoDB Enterprise Repository
baseurl=https://repo.mongodb.com/yum/redhat/\$releasever/mongodb-enterprise/5.0/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-5.0.asc" | sudo tee /etc/yum.repos.d/mongodb-enterprise-5.0.repo

# Install MongoDB
echo
echo Installing MongoDB...
yum install -y mongodb-enterprise
cp mongod.conf /etc

# auto-start
systemctl enable mongod

# Install Java (required by Java performance test client)
sudo yum install -y java-1.8.0-openjdk-devel

echo "Installation complete."
echo "Disabling SE Linux and rebooting..."
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
reboot

