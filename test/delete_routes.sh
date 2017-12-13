export GATEWAY_URL=$(kubectl get svc -n istio-system | grep -E 'istio-ingress' | awk '{ print $4 }')
NAMESPACE=default
for rule in $(istioctl get -n ${NAMESPACE} routerules); do
  istioctl delete -n ${NAMESPACE} routerule $rule > /dev/null 2>&1;
done
