#!/bin/sh
. delete_routes.sh
istioctl create -f ../nginmesh-0.2.12/samples/kubernetes/addons/route-rule-http-timeout.yaml > /dev/null 2>&1
sleep 5;
i=0 
l=0
while [ $l -le 9 ]
do    
     out=$(curl -s -w "Status_Code=%{http_code}\n" http://${GATEWAY_URL}/productpage)
      if  [[ $out == *"Status_Code=200"* ]]
      then
#        echo "Timeout works!";
         ((i++))
         ((l++))
       else
          ((l++)) 
      fi
done
   out1=$(kubectl exec -it $(kubectl get pod | grep productpage | awk '{ print $1 }') -c \
   istio-proxy cat /etc/istio/proxy/conf.d/http_0.0.0.0_9080.conf)
     if  [[ $out1 == *"uproxy_next_upstream_timeout"* && $out1 == *"proxy_next_upstream_tries"* ]]     
          then
          echo "HTTP Retry Test -- Passed"
          echo "| Retry Hit"=$i  "| Total Hit"=$l "|"
      elif [[ $i == 0 ]]
      then
          echo "App does not work!"
      else 
          echo "HTTP Retry does not work!"
       fi
. performance.sh
istioctl delete -f ../nginmesh-0.2.12/samples/kubernetes/addons/route-rule-http-timeout.yaml  > /dev/null 2>&1
      
   
