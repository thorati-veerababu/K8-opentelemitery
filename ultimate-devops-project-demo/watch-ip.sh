#!/bin/bash
echo "Waiting for External IP..."
while true; do
  IP=$(kubectl get svc -n envoy-gateway-system envoy-opentelimetry-otel-gateway-1b18ec63 -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
  if [ -n "$IP" ]; then
    echo "✅ External IP assigned: $IP"
    break
  fi
  echo -n "."
  sleep 5
done
