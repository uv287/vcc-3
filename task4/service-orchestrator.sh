#!/bin/bash

# Complete this script to deploy external-service and counter-service in two separate containers
# You will be using the conductor tool that you completed in task 3.

# git Creating link to the tool within this directory
# rm conductor.sh
# rm config.sh
ln -s ../task3/conductor.sh conductor.sh
sleep 1
ln -s ../task3/config.sh config.sh
sleep 1

# use the above scripts to accomplish the following actions -

# Logical actions to do:
# 1. Build image for the container

# sudo ./conductor.sh build mytask


# 2. Run two containers say c1 and c2 which should run in background. Tip: to keep the container running
#    in background you should use a init program that will not interact with the terminal and will not
#    exit. e.g. sleep infinity, tail -f /dev/null

sudo ./conductor.sh stop c1
sleep 2
sudo ./conductor.sh run mytask c1 "sleep inf" &
sleep 1

sudo ./conductor.sh stop c2
sudo ./conductor.sh run mytask c2 "sleep inf" &
sleep 2


# 3. Copy directory external-service to c1 and counter-service to c2 at appropriate location. You can
#    put these directories in the containers by copying them within ".containers/{c1,c2}/rootfs/" directory
sudo cp -r external-service .containers/c1/rootfs/
sleep 1

sudo cp -r counter-service .containers/c2/rootfs/
sleep 1
# 4. Configure network such that:
#    4.a: c1 is connected to the internet and c1 has its port 8080 forwarded to port 3000 of the host
sudo ./conductor.sh addnetwork c1 -e 8080-3000
sleep 1
#    4.b: c2 is connected to the internet and does not have any port exposed
sudo ./conductor.sh addnetwork c2
sleep 1
#    4.c: peer network is setup between c1 and c2
sudo ./conductor.sh peer c1 c2
sleep 1
# 5. Get ip address of c2. You should use script to get the ip address. 
#    You can use ip interface configuration within the host to get ip address of c2 or you can 
#    exec any command within c2 to get it's ip address

IP=$(sudo ./conductor.sh exec c2 -- hostname -I)
sleep 1
# 6. Within c2 launch the counter service using exec [path to counter-service directory within c2]/run.sh4
sudo ./conductor.sh exec c2 -- chmod +x /counter-service/run.sh
sudo ./conductor.sh exec c2 -- /counter-service/run.sh

# 7. Within c1 launch the external service using exec [path to external-service directory within c1]/run.sh
sudo ./conductor.sh exec c1 -- chmod +x /external-service/run.sh
sudo ./conductor.sh exec c2 -- /external-service/run.sh


# 8. Within your host system open/curl the url: http://localhost:3000 to verify output of the service
curl http://localhost:3000

# 9. On any system which can ping the host system open/curl the url: `http://<host-ip>:3000` to verify
#    output of the service
