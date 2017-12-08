#!/bin/sh
export GATEWAY_URL=$(kubectl get svc -n istio-system | grep -E 'istio-ingress' | awk '{ print $4 }')
NAMESPACE=default
for rule in $(istioctl get -n ${NAMESPACE} routerules); do
  istioctl delete -n ${NAMESPACE} routerule $rule;
done
istioctl create -f ../nginmesh-0.2.12/samples/kubernetes/addons/route-rule-http-redirect.yaml
sleep 5;
i=0 
j=0
k=0
l=0
while [ $l -le 9 ]
do
    out=$(curl -s -w "Status_Code=%{http_code}\n" http://${GATEWAY_URL}/productpage)
      if  [[ $out == *"Status_Code=301"* ]]
      then
#        echo "Redirect works!";
         ((i++))
         ((l++))
       else
          ((l++)) 
      fi
done
     if  [[ $i>0 ]] 
        then
          echo "HTTP Redirect Test -- Passed"
          echo "| Redirect Hit"=$i  "| Total Hit"=$l "|"
      elif [[ $i=0 ]] 
      then
          echo "HTTP Redirect does not work!"
       fi
istioctl delete -f ../nginmesh-0.2.12/samples/kubernetes/addons/route-rule-http-redirect.yaml
      
   
