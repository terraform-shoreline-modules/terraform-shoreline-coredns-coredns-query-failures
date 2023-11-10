
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# CoreDNS Query Failures

CoreDNS Query Failures is an incident type that indicates that there is an issue with the CoreDNS service which is responsible for resolving DNS queries in a system. This incident can occur due to various reasons such as network connectivity issues, DNS misconfiguration, or a bug in the CoreDNS software itself. When this incident happens, users may experience difficulties accessing services or websites that rely on DNS resolution. Troubleshooting this incident requires identifying the root cause and implementing a solution to resolve the issue and restore normal functionality.

### Parameters

```shell
export COREDNS_POD_NAME="PLACEHOLDER"
export POD_NAME="PLACEHOLDER"
export DOMAIN_NAME="PLACEHOLDER"
export NAMESPACE="PLACEHOLDER"
export COREDNS_CONFIGMAP_NAME="PLACEHOLDER"
export DNS_SERVER_IP="PLACEHOLDER"
export COREDNS_DEPLOYMENT_NAME="PLACEHOLDER"
```

## Debug

### Next Step

```shell
shell
# Get list of pods in the kube-system namespace
kubectl get pods -n kube-system
```

### Check logs of CoreDNS pods for errors or failures

```shell
kubectl logs ${COREDNS_POD_NAME} -n kube-system
```

### Get detailed information about the CoreDNS Deployment

```shell
kubectl describe deployment coredns -n kube-system
```

### Check the status of the CoreDNS Service

```shell
kubectl get svc coredns -n kube-system
```

### Check if the CoreDNS ConfigMap is correct

```shell
kubectl describe configmap coredns -n kube-system
```

### Check if the Kubernetes DNS service is running

```shell
kubectl get svc kube-dns -n kube-system
```

### Check if the Kubernetes DNS ConfigMap is correct

```shell
kubectl describe cm coredns -n kube-system
```

### Check if the pod's DNS settings are correct

```shell
kubectl exec ${POD_NAME} -- nslookup ${DOMAIN_NAME}
```

### Check if the DNS policy for the pod is set to the correct value

```shell
kubectl describe pod ${POD_NAME} | grep DNS
```

### Check if there are any network connectivity issues

```shell
kubectl exec ${POD_NAME} -- ping ${DOMAIN_NAME}
```

## Repair

### Restart the CoreDNS service: If the issue is isolated to the CoreDNS service, restarting the service may be enough to resolve the issue.

```shell
#!/bin/bash

# Set the namespace where CoreDNS is running
NAMESPACE=${NAMESPACE}

# Set the name of the CoreDNS pod
POD_NAME=$(kubectl get pods -n $NAMESPACE -l k8s-app=kube-dns -o jsonpath='{.items[0].metadata.name}')

# Restart the CoreDNS service
kubectl delete pod $POD_NAME -n $NAMESPACE
```

### Verify DNS configuration: Ensure that the DNS configuration is correct and that the CoreDNS service is configured to use the correct DNS servers. Misconfiguration of DNS can cause query failures and lead to this incident type.

```shell
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
```