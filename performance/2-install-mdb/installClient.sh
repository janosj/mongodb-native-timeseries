# Check for sudo user.
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
yum install -y nodejs
npm install -g mgeneratejs
yum install -y https://fastdl.mongodb.org/tools/db/mongodb-database-tools-rhel80-x86_64-100.3.1.rpm

# Note: this is the new mongosh that replaces the original mongo shell.
# Caused a JavaScript heap out of memory when running runSlowQueries.
yum install -y https://downloads.mongodb.com/compass/mongodb-mongosh-1.1.7.el8.x86_64.rpm

# Installs the standard mongo shell.
# yum install -y https://repo.mongodb.com/yum/redhat/8/mongodb-enterprise/4.4/x86_64/RPMS/mongodb-enterprise-shell-4.4.6-1.el8.x86_64.rpm

# Install Java (required by Java performance test client)
sudo yum install -y java-1.8.0-openjdk-devel


