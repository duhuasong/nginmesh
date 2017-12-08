#!/bin/sh
export GATEWAY_URL=$(kubectl get svc -n istio-system | grep -E 'istio-ingress' | awk '{ print $4 }')
NAMESPACE=default
for rule in $(istioctl get -n ${NAMESPACE} routerules); do
  istioctl delete -n ${NAMESPACE} routerule $rule;
done
istioctl create -f ../nginmesh-0.2.12/samples/kubernetes/route-rule-reviews-v3.yaml
sleep 5;
i=0 
j=0
k=0
l=0
while [ $l -le 9 ]
do
    out=$(curl -s -w "Status_Code=%{http_code}\n" http://${GATEWAY_URL}/productpage)
      if  [[ $out == *"Status_Code=200"* && ! ( $out == *'color="black"'* ||  $out == *'color="red"'*) ]]
      then
#        echo "Reviews V1 works!";
         ((i++))
         ((l++))
      elif [[ $out == *"black"* ]] && [[ $out == *"Status_Code=200"* ]]
        then
#            echo "Reviews V2 works!";
             ((j++))
             ((l++))
      elif [[ $out == *"red"* ]] && [[ $out == *"Status_Code=200"* ]] 
        then
#         echo "Reviews V3 works!"
          ((k++))         
          ((l++))
       else
          ((l++)) 
      fi
done
     if  [[ $i=0 && $j=0 && $k>0 ]] 
        then
          echo "Route all to V3 Test -- Passed"
          echo "| V1 Hit"=$i  "| V2 Hit"=$j "| V3 Hit"=$k "| Total Hit"=$l "|"
      elif [[ $k=0 ]] 
      then
          echo "App V3 does not work!"
      elif [[ $i > 0 || $j > 0 ]]
      then
          echo "Route all to V3 does not work!"
       fi
istioctl delete -f ../nginmesh-0.2.12/samples/kubernetes/route-rule-reviews-v3.yaml
      
   
