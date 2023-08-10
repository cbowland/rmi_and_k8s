#!/bin/bash

########################
# include the magic
#
# p    - print only, do not execute
# pe   - print and execute when enter is pressed
# pei  - print and execute immediately
# wait - wait until enter is pressed
# cmd  - interactive mode
#      - run commands behind the scenes, can be useful for hiding sensitive information
#
########################

########################
# $ ./my-demo.sh -h
# 
# Usage: ./my-demo.sh [options]
# 
#   Where options is one or more of:
#   -h  Prints Help text
#   -d  Debug mode. Disables simulated typing
#   -n  No wait
#   -w  Waits max the given amount of seconds before proceeding with demo (e.g. `-w5`)
########################

# path to demo magic shell script
DEMO_MAGIC=

# source demo magic shell script
. $DEMO_MAGIC


# hide the evidence
clear

# OpenShift credentials
PUBLIC_CLUSTER_USER=
PUBLIC_CLUSTER_PASSWORD=
PUBLIC_CLUSTER_API=
PUBLIC_CLUSTER_PROJECT=

# skupper console credentials
PUBLIC_CLUSTER_CONSOLE_USER=
PUBLIC_CLUSTER_CONSOLE_PASSWORD=

# print title
p "Starting Skupper RMI and K8S Demo"

# build and push container image
p "View the Containerfile for the QuoteOfTheDay Client"
pe 'cat ../Containerfile_qotd_client'
yes '' | head -n3
p 'Build QuoteOfTheDay Client Container Image'
pe 'podman build -t rmi_qotd_client -f ../Containerfile_qotd_client'
pe 'podman tag rmi_qotd_client:latest quay.io/cbowland/rmi_qotd_client'
yes '' | head -n3
p "Push QuoteOfTheDay Client Container Image to Quay"
pe 'podman push quay.io/cbowland/rmi_qotd_client'
yes '' | head -n3

# login to the cluster
pe 'oc login -u $PUBLIC_CLUSTER_USER -p $PUBLIC_CLUSTER_PASSWORD --server $PUBLIC_CLUSTER_API'
pe 'oc new-project $PUBLIC_CLUSTER_PROJECT'
pe 'oc config set-context $(oc config current-context) --namespace=$PUBLIC_CLUSTER_PROJECT'
pe 'oc config rename-context $(oc config current-context) $PUBLIC_CLUSTER_PROJECT'
yes '' | head -n3

# relax pod security to supress warnings in public cluster
p 'set some labels on the namespace'
oc label ns $PUBLIC_CLUSTER_PROJECT security.openshift.io/scc.podSecurityLabelSync=false
oc label --overwrite ns $PUBLIC_CLUSTER_PROJECT \
        pod-security.kubernetes.io/enforce=privileged \
        pod-security.kubernetes.io/warn=baseline \
        pod-security.kubernetes.io/audit=baseline
yes '' | head -n3

# deploy the QuoteOfTheDay Container Image
pe 'oc apply -f ../deployment.yaml'
# check the logs (should be a failure)
pe 'oc get pods -l app=rmi-qotd'
pe 'oc logs --tail=30 -l app=rmi-qotd'
yes '' | head -n3
p 'Task failed successfully ;-)'
yes '' | head -n3
# scale app to 0
pe 'oc scale --replicas=0 deployments/rmi-qotd'
yes '' | head -n3

# initialize skupper
p "The 'skupper init' command installs the Skupper router and service controller in the current namespace"
pe 'skupper init --enable-console --enable-flow-collector --console-auth=internal --console-user=$PUBLIC_CLUSTER_CONSOLE_USER --console-password=$PUBLIC_CLUSTER_CONSOLE_PASSWORD'
yes '' | head -n3

# skupper console
p "Skupper includes a web console you can use to view the application network"
yes '' | head -n1
pe "skupper status"
yes '' | head -n3

# install the local skupper gateway
p "The 'skupper gateway init' command starts a Skupper router on your local system and links it to the Skupper router in the current Kubernetes namespace"
pe "skupper gateway init --type podman"
pe "skupper gateway status"
yes '' | head -n3

# check the podman container
pe "podman ps"
yes '' | head -n3

# project status (no services)
pe "oc status"
pe "oc get services"
yes '' | head -n3

# expose backend RMI Registry and Service
p "Use 'skupper service create' to define a Skupper service called rmi-server"
p "Then use 'skupper gateway bind' to attach your running backend process as a target for the service"
yes '' | head -n3
pe "skupper service create rmi-server 1099 5000"
pe "skupper gateway bind rmi-server localhost 1099 5000"
pe "skupper gateway status"
yes '' | head -n3

# project status (should have the rmi-server service)
pe "oc status"
pe "oc get services"
yes '' | head -n3


# test everything
p "start the app again"
pe "oc scale --replicas=1 deployments/rmi-qotd"
yes '' | head -n3
p "Check the logs in the running container"
pe "oc logs -f -l app=rmi-qotd"
yes '' | head -n3

p "just for fun, scale the app up"
pe "oc scale --replicas=2 deployments/rmi-qotd"
pe "oc get pods"
yes '' | head -n3

# end demo
p "Completing Skupper RMI and K8S Demo"

wait

# clean up
skupper gateway delete
skupper delete
oc delete project $PUBLIC_CLUSTER_PROJECT
oc config delete-context $PUBLIC_CLUSTER_PROJECT
