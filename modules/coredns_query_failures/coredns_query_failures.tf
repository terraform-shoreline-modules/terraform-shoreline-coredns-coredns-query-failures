resource "shoreline_notebook" "coredns_query_failures" {
  name       = "coredns_query_failures"
  data       = file("${path.module}/data/coredns_query_failures.json")
  depends_on = [shoreline_action.invoke_get_pods_kubesys,shoreline_action.invoke_restart_coredns,shoreline_action.invoke_dns_update]
}

resource "shoreline_file" "get_pods_kubesys" {
  name             = "get_pods_kubesys"
  input_file       = "${path.module}/data/get_pods_kubesys.sh"
  md5              = filemd5("${path.module}/data/get_pods_kubesys.sh")
  description      = "Next Step"
  destination_path = "/tmp/get_pods_kubesys.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "restart_coredns" {
  name             = "restart_coredns"
  input_file       = "${path.module}/data/restart_coredns.sh"
  md5              = filemd5("${path.module}/data/restart_coredns.sh")
  description      = "Restart the CoreDNS service: If the issue is isolated to the CoreDNS service, restarting the service may be enough to resolve the issue."
  destination_path = "/tmp/restart_coredns.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "dns_update" {
  name             = "dns_update"
  input_file       = "${path.module}/data/dns_update.sh"
  md5              = filemd5("${path.module}/data/dns_update.sh")
  description      = "Verify DNS configuration: Ensure that the DNS configuration is correct and that the CoreDNS service is configured to use the correct DNS servers. Misconfiguration of DNS can cause query failures and lead to this incident type."
  destination_path = "/tmp/dns_update.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_get_pods_kubesys" {
  name        = "invoke_get_pods_kubesys"
  description = "Next Step"
  command     = "`chmod +x /tmp/get_pods_kubesys.sh && /tmp/get_pods_kubesys.sh`"
  params      = []
  file_deps   = ["get_pods_kubesys"]
  enabled     = true
  depends_on  = [shoreline_file.get_pods_kubesys]
}

resource "shoreline_action" "invoke_restart_coredns" {
  name        = "invoke_restart_coredns"
  description = "Restart the CoreDNS service: If the issue is isolated to the CoreDNS service, restarting the service may be enough to resolve the issue."
  command     = "`chmod +x /tmp/restart_coredns.sh && /tmp/restart_coredns.sh`"
  params      = ["NAMESPACE","POD_NAME"]
  file_deps   = ["restart_coredns"]
  enabled     = true
  depends_on  = [shoreline_file.restart_coredns]
}

resource "shoreline_action" "invoke_dns_update" {
  name        = "invoke_dns_update"
  description = "Verify DNS configuration: Ensure that the DNS configuration is correct and that the CoreDNS service is configured to use the correct DNS servers. Misconfiguration of DNS can cause query failures and lead to this incident type."
  command     = "`chmod +x /tmp/dns_update.sh && /tmp/dns_update.sh`"
  params      = ["DNS_SERVER_IP","COREDNS_CONFIGMAP_NAME","COREDNS_DEPLOYMENT_NAME"]
  file_deps   = ["dns_update"]
  enabled     = true
  depends_on  = [shoreline_file.dns_update]
}

