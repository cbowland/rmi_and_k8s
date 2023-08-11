# Java RMI and Kubernetes

Investigate rmi clients in k8s using rmi services running remotely

[website]: https://skupper.io/

#### Contents

* [Overview](#overview)
* [Prerequisites](#prerequisites)
* [Build Instructions](#build-instructions)
* [Run the Code Locally](#run-the-code-locally)
* [Run in Containers](#run-in-containers)
* [Run in OpenShift](#run-in-openshift)
* [Demo Magic](#demo-magic)

## Overview

This is an example of using Skupper to decouple an RMI
Client from an RMI Server and Registry and running that 
client inside of a remote OpenShift cluster while leaving the
Registry and Server running locally in bare metal host.
across a Kubernetes cluster and a bare-metal host or VM.

The example RMI application has a client that will call a 
method on a remote object. Intially, we will run everything 
locally but eventually we will run just the client in a 
remote OpenShift cluster.

One of the goals for this demo is to show how parts of an
application can be moved **unchanged** into a remote 
OpenShit cluster by using skupper to wire everything
together.

## Prerequisites

* A Java SDK([Software Develoepr Kit Manager][sdk-man])

* A working installation of Podman ([installation guide][install-podman])

* The `oc` command-line tool, version 4.12 or later
  ([installation guide][install-oc-cli])

* The `skupper` command-line tool, version 1.4 or later
  ([installation guide][skupper-cli])

* Access to an Openshift cluster

[sdk-man]: https://sdkman.io/
[install-podman]: https://podman.io/getting-started/installation
[install-oc-cli]: https://docs.openshift.com/container-platform/4.12/cli_reference/openshift_cli/getting-started-cli.html#installing-openshift-cli
[skupper-cli]: https://access.redhat.com/documentation/en-us/red_hat_service_interconnect/1.4/html-single/installation/index#installing-skupper-cli


## Build Instructions
* set up directories
  * rm -rf target
  * mkdir target
* compile server
  * javac -d target src/server/*.java
* create server jar
  * jar cvf target/rmi-server.jar -C target server
* compile client
  * javac -cp target/rmi-server.jar -d target src/client/*.java
* create rmi jar
  * jar cvf target/rmi-lib.jar -C target server/Qotd.class
* create client jar
  * jar cvf target/rmi-client.jar -C target client

## Run the Code Locally
* run rmi registry
  * CLASSPATH=target/rmi-lib.jar $JAVA_HOME/bin/rmiregistry
![Screenshot 2023-07-01 at 2 58 29 PM](https://github.com/cbowland/rmi_and_k8s/assets/1307303/8a959e23-f5e4-400f-9a47-e44d5553c4ce)

* run server
  * java -cp target/rmi-server.jar server.Server 1099
![Screenshot 2023-07-01 at 2 59 53 PM](https://github.com/cbowland/rmi_and_k8s/assets/1307303/02c10372-20f2-47e9-8dbd-09ba65823e12)

* execute client
  * java -cp target/rmi-client.jar:target/rmi-lib.jar client.QotdClient localhost 1099 
![Screenshot 2023-07-01 at 3 00 55 PM](https://github.com/cbowland/rmi_and_k8s/assets/1307303/afa25c5d-b087-482a-8dd2-4256c85f3760)


## Run In Containers

_build the 3 images_
  * podman build -t rmi_registry -f Containerfile_registry
  * podman build -t rmi_client -f Containerfile_qotd_client
  * podman build -t rmi_server -f Containerfile_server

_run the registry, server, and client_
  * podman run --rm --network=host --name rmi_registry rmi_registry:latest
  * podman run --rm --network=host --name rmi_server rmi_server:latest
  * podman run --rm --network=host --name rmi_client rmi_client:latest

## Run In OpenShift

Be sure the registry and the server are running locally.
It does not matter if they are running directly or in containers
or even one in each, but they do need to be running so that the client running
in Openshift has something to connect to (once we have Skupper set up).

When running the client in OpenShift and the server locally, you will need to set
the hostname to be the same as the skupper service that you create below. 

In this example, I will use rmi_server as the hostname. You can modify your local
/etc/hosts file to add rmi_server to resolve your localhost ip address.

If you follow those instructions, here is how run the server:

* java -Djava.rmi.server.hostname=rmi-server -cp target/rmi-server.jar server.Server 1099

It's exactly the same as the version at the top, but with the addition of
"-Djava.rmi.server.hostname=rmi-server" to match skupper service. See
https://docs.oracle.com/javase/8/docs/technotes/guides/rmi/javarmiproperties.html
for additional details.

#### Install Skupper locally
  * Follow the instructions here: https://skupper.io/install/index.html
  * You will also need Podman or Docker as well

#### Log in to OpenShift
  * oc login -u -p --you know the drill

#### Install the skupper operator
  * go to operator hub, search for skupper, install with defaults

#### Create a new project (any name is fine)
  * oc new-project aardvark

#### Set up skupper in project
  * skupper init --enable-console --enable-flow-collector

#### Set up skupper locally
  * skupper gateway init --type=podman
  * skupper service create rmi-server 1099 5000
  * skupper gateway bind rmi-server localhost 1099 5000

#### Deploy client code to openshift
  * oc apply -f deployment.yaml
    

You might want to edit the deployment.yaml and use a
different image if you have built one. This would require
pushing your image to your own image repo and then updating the
deployment.yaml to use that image.

#### Check the logs for the client container
  
They should look the same as when run locally.

![Screenshot 2023-07-03 at 10 38 12 AM](https://github.com/cbowland/rmi_and_k8s/assets/1307303/683863c8-de6f-446c-adad-db06b317a5bf)

## Demo Magic 

You can also use the Demo Magic script to automate the
OpenShift bits. There are several variables in that script
that need to be set before running it.

**Demo Magic Script Varibles:**

~~~ shell
# path to demo magic shell script
DEMO_MAGIC=

# OpenShift credentials
PUBLIC_CLUSTER_USER=
PUBLIC_CLUSTER_PASSWORD=
PUBLIC_CLUSTER_API=
PUBLIC_CLUSTER_PROJECT=

# skupper console credentials
PUBLIC_CLUSTER_CONSOLE_USER=
PUBLIC_CLUSTER_CONSOLE_PASSWORD=
~~~

_Run Demo Magic Script_
~~~ shell
bash demo.sh
~~~

_Demo Magic Sample Output_



https://github.com/cbowland/rmi_and_k8s/assets/1307303/8906d94b-b7e4-4559-bf47-daa520a811e2

