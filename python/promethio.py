import subprocess
import time


GATEWAY_URL = str(subprocess.check_output("kubectl get svc -n istio-system | grep -E 'istio-ingress' | awk '{ print $4 }'", universal_newlines=True,shell=True)).rstrip()

subprocess.check_output("ps -ef | grep prometheus | grep -v grep | awk '{print $2}' | xargs kill -9",universal_newlines=True,shell=True)

subprocess.check_output("kubectl apply -f ../istio-0.2.12/install/kubernetes/addons/prometheus.yaml",universal_newlines=True,shell=True)

time.sleep(5)

subprocess.check_output("kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090 &",universal_newlines=True,shell=True)


output = str(subprocess.check_output("wrk -t1 -c10 -d1s http://"+GATEWAY_URL+"/productpage | grep -E 'Requests|Transfer|requests|responses'", universal_newlines=True,shell=True)).rstrip()
print(output)

output1 = str(subprocess.check_output("curl -s -X GET 'http://localhost:9090/api/v1/query?query=request_count' -H 'accept: application/json'", universal_newlines=True,shell=True)).rstrip()

if 'productpage' in output1:
    print("Prometheus Test -- Passed")
else:
    print("Prometheus Test -- Failed")


#subprocess.check_output("ps -ef | grep prometheus | grep -v grep | awk '{print $2}' | xargs kill -9  > /dev/null 2>&1",universal_newlines=True,shell=True)

#subprocess.check_output("kubectl delete -f ../istio-0.2.12/install/kubernetes/addons/prometheus.yaml > /dev/null 2>&1",universal_newlines=True,shell=True)





