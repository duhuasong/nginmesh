import subprocess
import time


GATEWAY_URL = str(subprocess.check_output("kubectl get svc -n istio-system | grep -E 'istio-ingress' | awk '{ print $4 }'", universal_newlines=True,shell=True)).rstrip()

subprocess.check_output("istioctl create -f ../nginmesh-0.2.12/samples/kubernetes/addons/route-rule-http-rewrite.yaml > /dev/null 2>&1",universal_newlines=True,shell=True)

time.sleep(5)


v1_count=0
total_count = 0

while total_count < 10:
    output = str(subprocess.check_output("curl -s -w 'Status_Code=%{http_code}\n' http://"+GATEWAY_URL+"/productpage", universal_newlines=True,shell=True)).rstrip()
    if 'Status_Code=200' in output:
       # print("App works!")
        total_count += 1
        v1_count+=1
    else:
        print("App does not work!")
        total_count += 1

output1=str(subprocess.check_output("kubectl logs $(kubectl get pod -n istio-system | grep istio-mixer | awk '{ print $1 }') -n istio-system mixer | grep 'request.path                  : /v1/bookRatings/0'", universal_newlines=True,shell=True)).rstrip()

if 'bookRatings' in output1:
    print("HTTP Rewrite  Test -- Passed")
    print("| Rewrite Hit=",v1_count,"| Total Hit=",total_count," |")
elif v1_count==0:
    print("HTTP Rewrite does not work!")

output2 = str(subprocess.check_output("wrk -t1 -c10 -d1s http://"+GATEWAY_URL+"/productpage | grep -E 'Requests|Transfer|requests|responses'", universal_newlines=True,shell=True)).rstrip()
print(output2)

subprocess.check_output("istioctl delete -f ../nginmesh-0.2.12/samples/kubernetes/addons/route-rule-http-rewrite.yaml > /dev/null 2>&1",universal_newlines=True,shell=True)


