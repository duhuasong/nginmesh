#!/bin/sh
export GATEWAY_URL=$(kubectl get svc -n istio-system | grep -E 'istio-ingress' | awk '{ print $4 }')
NAMESPACE=default
for rule in $(istioctl get -n ${NAMESPACE} routerules); do
  istioctl delete -n ${NAMESPACE} routerule $rule;
done
istioctl create -f ../nginmesh-0.2.12/samples/kubernetes/addons/route-rule-http-rewrite.yaml
sleep 5;
i=0 
l=0
while [ $l -le 9 ]
do    
     out=$(curl -s -w "Status_Code=%{http_code}\n" http://${GATEWAY_URL}/productpage)
      if  [[ $out == *"Status_Code=200"* ]]
      then
#        echo "Rewrite works!";
         ((i++))
         ((l++))
       else
          ((l++)) 
      fi
done
   out1=$(kubectl logs $(kubectl get pod -n istio-system | grep istio-mixer | awk '{ print $1 }') \
     -n istio-system mixer | grep 'request.path                  : /v1/bookRatings/0')
     if  [[ $out1 == *"bookRatings"* ]]     
          then
          echo "HTTP Rewrite Test -- Passed"
          echo "| Rewrite Hit"=$i  "| Total Hit"=$l "|"
      elif [[ $i == 0 ]]
      then
          echo "App does not work!"
      else 
          echo "HTTP Rewrite does not work!"
       fi
istioctl delete -f ../nginmesh-0.2.12/samples/kubernetes/addons/route-rule-http-rewrite.yaml
      
   