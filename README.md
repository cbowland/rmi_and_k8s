# Java RMI and Kubernetes
Investigate rmi clients in k8s using rmi services running remotely


## Build Instructions
* set up directories
  * rm -rf target
  * mkdir target
* compile
  * javac -d target src/server/*.java
* create server jar
  * jar cvf target/rmi-server.jar -C target server
* create rmi jar
  * jar cvf target/rmi-lib.jar -C target server/Greeting.class
* create client jar
  * jar cvf target/rmi-client.jar -C target client

## Run the Code
* run rmi registry
  * CLASSPATH=target/rmi-lib.jar $JAVA_HOME/bin/rmiregistry
![Screenshot 2023-07-01 at 2 58 29 PM](https://github.com/cbowland/rmi_and_k8s/assets/1307303/8a959e23-f5e4-400f-9a47-e44d5553c4ce)

* run server
  * java -cp target/rmi-server.jar server.Server 1099
![Screenshot 2023-07-01 at 2 59 53 PM](https://github.com/cbowland/rmi_and_k8s/assets/1307303/02c10372-20f2-47e9-8dbd-09ba65823e12)

* execute client
  * java -cp target/rmi-client.jar:target/rmi-lib.jar client.Client localhost 1099 steve
![Screenshot 2023-07-01 at 3 00 55 PM](https://github.com/cbowland/rmi_and_k8s/assets/1307303/afa25c5d-b087-482a-8dd2-4256c85f3760)


## Container Stuff

* build the 3 images
  * podman build -t rmi_registry -f Containerfile_registry
  * podman build -t rmi_client -f Containerfile_client
  * podman build -t rmi_server -f Containerfile_server

* run the registry and server
  * podman run --rm --network=host --name rmi_registry rmi_registry:latest
  * podman run --rm --network=host --name rmi_server rmi_server:latest

* run client with default name
  * podman run --rm --network=host --name rmi_client rmi_client:latest
* run client passing in NAME environment variable
  * podman run --rm --network=host --name rmi_client -e NAME=bob rmi_client:latest

## OpenShift Stuff

Be sure the registry and the server are running locally.
It does not matter if they are running directly or in containers
or even one in each, but they do need to be running so that the client running
in Openshift has something to connect to (once we have Skupper set up).

* Install Skupper locally
  * Follow the instructions here: https://skupper.io/install/index.html
  * You will also need Podman or Docker as well

* oc login -u -p --you know the drill

* install the skupper operator
  * go to operator hub, search for skupper, install with defaults

* create a new project (any name is fine)
  * oc new-project aardvark

* set up skupper in project
  * skupper init --enable-console --enable-flow-collector

* set up skupper locally
  * skupper gateway init --type=podman
  * skupper service create rmi-server 1099
  * skupper gateway bind rmi-server localhost 1099

* deploy client code to openshift
  * oc apply -f deployment.yaml
    

You might want to edit the deployment.yaml and use a
different image if you have built one. This would require
pushing your image to your own image repo and then updating the
deploymet.yaml to use that image.


* check the logs for the client container
  
They should look the same as when run locally.
See screenshot above for an example.

You will see the connection to the registry work

![Screenshot 2023-07-02 at 10 01 13 AM](https://github.com/cbowland/rmi_and_k8s/assets/1307303/37c58bec-a572-4563-a981-7b1acebe2814)

but the remote object method call times out and i'm not sure why

![Screenshot 2023-07-02 at 10 19 08 AM](https://github.com/cbowland/rmi_and_k8s/assets/1307303/3f32a9fe-ae9a-449d-a6e0-af72dec6019c)


 
