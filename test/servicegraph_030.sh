ps -ef | grep prometheus | grep -v grep | awk '{print $2}' | xargs kill -9  > /dev/null 2>&1
ps -ef | grep servicegraph | grep -v grep | awk '{print $2}' | xargs kill -9  > /dev/null 2>&1

export GATEWAY_URL=$(kubectl get svc -n istio-system | grep -E 'istio-ingress' | awk '{ print $4 }')

kubectl apply -f ../istio-0.2.12/install/kubernetes/addons/prometheus.yaml > /dev/null 2>&1
kubectl apply -f ../istio-0.3.0/install/kubernetes/addons/servicegraph.yaml > /dev/null 2>&1
sleep 15;
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090 & > /dev/null 2>&1
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=servicegraph -o jsonpath='{.items[0].metadata.name}') 8088:8088 & > /dev/null 2>&1

. performance.sh

 out=$(curl -s -X GET "http://localhost:8088/graph" -H "accept: application/json")

      if  [[ $out == *"productpage"* ]]
      then
       echo "Servicegraph Test -- Passed";
      else
      echo "Servicegraph Test -- Failed";
      fi

kubectl delete -f ../istio-0.3.0/install/kubernetes/addons/servicegraph.yaml > /dev/null 2>&1
ps -ef | grep servicegraph | grep -v grep | awk '{print $2}' | xargs kill -9  > /dev/null 2>&1
kubectl delete -f ../istio-0.2.12/install/kubernetes/addons/prometheus.yaml > /dev/null 2>&1
ps -ef | grep prometheus | grep -v grep | awk '{print $2}' | xargs kill -9  > /dev/null 2>&1





