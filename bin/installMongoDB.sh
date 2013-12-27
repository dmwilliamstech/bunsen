mv 10gen.repo /etc/yum.repos.d/
yum install mongo-10gen mongo-10gen-server
echo "setParameter= textSearchEnabled=true" >> /etc/mongod.conf
chkconfig mongod on
