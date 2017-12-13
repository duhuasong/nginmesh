ps -ef | grep grafana | grep -v grep | awk '{print $2}' | xargs kill -9
ps -ef | grep prometheus | grep -v grep | awk '{print $2}' | xargs kill -9  > /dev/null 2>&1
export GATEWAY_URL=$(kubectl get svc -n istio-system | grep -E 'istio-ingress' | awk '{ print $4 }')

kubectl apply -f ../istio-0.2.12/install/kubernetes/addons/prometheus.yaml > /dev/null 2>&1
kubectl apply -f ../istio-0.2.12/install/kubernetes/addons/grafana.yaml > /dev/null 2>&1
sleep 25;

kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090 & > /dev/null 2>&1
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000 & > /dev/null 2>&1


. performance.sh
file_name=grafana_$(date +"%Y_%m_%d_%I_%M_%p");
curl -s "http://localhost:3000/render/dashboard-solo/db/istio-dashboard?orgId=1&panelId=54&width=1000&height=500" > $file_name.png
[ -f $file_name.png ] && echo "Grafana Test -- Passed. Please, check $file_name.png for data." || echo "Grafana Test -- Failed"
kubectl delete -f ../istio-0.2.12/install/kubernetes/addons/grafana.yaml > /dev/null 2>&1
ps -ef | grep grafana | grep -v grep | awk '{print $2}' | xargs kill -9  > /dev/null 2>&1
kubectl delete -f ../istio-0.2.12/install/kubernetes/addons/prometheus.yaml > /dev/null 2>&1
ps -ef | grep prometheus | grep -v grep | awk '{print $2}' | xargs kill -9  > /dev/null 2>&1
