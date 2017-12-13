ps -ef | grep zipkin | grep -v grep | awk '{print $2}' | xargs kill -9
export GATEWAY_URL=$(kubectl get svc -n istio-system | grep -E 'istio-ingress' | awk '{ print $4 }')
kubectl apply -f ../istio-0.2.12/install/kubernetes/addons/zipkin.yaml
sleep 20;
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=zipkin -o jsonpath='{.items[0].metadata.name}') 9411:9411 &

. performance.sh
sleep 20;
 out=$(curl -s -X GET "http://localhost:9411/api/v2/services" -H "accept: application/json" )

# out1=$(curl -s -X GET "http://localhost:9411/api/v2/spans?serviceName=productpage" -H "accept: application/json")
 # $out1 == *"details"* &&
 #out2=$(curl -s -X GET "http://localhost:9411/api/v2/traces?serviceName=productpage&limit=1" -H "accept: #application/json") # && $out2 == *"sidecar"*

      if  [[ $out == *"productpage"* ]]
      then
       echo "Zipkin Test -- Passed";
      else
      echo "Zipkin Test -- Failed";
      fi


kubectl delete -f ../istio-0.2.12/install/kubernetes/addons/zipkin.yaml > /dev/null 2>&1
ps -ef | grep zipkin | grep -v grep | awk '{print $2}' | xargs kill -9  > /dev/null 2>&1
