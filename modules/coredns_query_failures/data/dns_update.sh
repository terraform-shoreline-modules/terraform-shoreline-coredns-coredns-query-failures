#!/bin/bash

# Set the DNS server IP address
DNS_SERVER=${DNS_SERVER_IP}

# Set the CoreDNS ConfigMap name
COREDNS_CONFIG=${COREDNS_CONFIGMAP_NAME}

# Set the CoreDNS Deployment name
COREDNS_DEPLOYMENT=${COREDNS_DEPLOYMENT_NAME}

# Update the CoreDNS ConfigMap to use the correct DNS server
kubectl patch configmap $COREDNS_CONFIG -n kube-system --type merge -p '{"data": {"Corefile": ".:53 {\n    forward . '$DNS_SERVER' \n}\n"}}'

# Restart the CoreDNS Deployment to apply the updated ConfigMap
kubectl rollout restart deployment $COREDNS_DEPLOYMENT -n kube-system

# Wait for the deployment to complete
kubectl rollout status deployment $COREDNS_DEPLOYMENT -n kube-system