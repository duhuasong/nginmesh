#!/bin/sh
. delete_routes.sh
istioctl create -f ../nginmesh-0.2.12/samples/kubernetes/route-rule-all-v1.yaml > /dev/null 2>&1
istioctl create -f ../nginmesh-0.2.12/samples/kubernetes/route-rule-reviews-test-v2.yaml > /dev/null 2>&1

sleep 7;
i=0 
j=0
k=0
l=0
while [ $l -le 9 ]
do
      out=$(curl -s --cookie "user=jason" -w "Status_Code=%{http_code}\n" http://${GATEWAY_URL}/productpage)
      if  [[ $out == *"Status_Code=200"* && ! ( $out == *'color="black"'* ||  $out == *'color="red"'*) ]]
      then
#        echo "Reviews V1 works!";
         ((i++))
         ((l++))
      elif [[ $out == *'color="black"'* ]] && [[ $out == *"Status_Code=200"* ]]
        then
#            echo "Reviews V2 works!";
             ((j++))
             ((l++))
      elif [[ $out == *'color="red"'* ]] && [[ $out == *"Status_Code=200"* ]] 
        then
#         echo "Reviews V3 works!"
          ((k++))         
          ((l++))
       else
          ((l++)) 
      fi
done
     if  [[ $i=0 && $j>0 && $k=0 ]] 
        then
          echo "Route "jason" user to V2 Test -- Passed"
          echo "| V1 Hit"=$i  "| V2 Hit"=$j "| V3 Hit"=$k "| Total Hit"=$l "|"
      elif [[ $j=0 ]] 
      then
          echo "App route "jason" user to V2 does not work!"
      elif [[ $i > 0 || $k > 0 ]]
      then
          echo "Route "jason" user to V2 does not work!"
       fi
. performance.sh
istioctl delete -f ../nginmesh-0.2.12/samples/kubernetes/route-rule-all-v1.yaml > /dev/null 2>&1
istioctl delete -f ../nginmesh-0.2.12/samples/kubernetes/route-rule-reviews-test-v2.yaml > /dev/null 2>&1     
   
