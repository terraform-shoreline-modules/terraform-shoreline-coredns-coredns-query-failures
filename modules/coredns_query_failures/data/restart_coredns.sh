#!/bin/bash

# Set the namespace where CoreDNS is running
NAMESPACE=${NAMESPACE}

# Set the name of the CoreDNS pod
POD_NAME=$(kubectl get pods -n $NAMESPACE -l k8s-app=kube-dns -o jsonpath='{.items[0].metadata.name}')

# Restart the CoreDNS service
kubectl delete pod $POD_NAME -n $NAMESPACE