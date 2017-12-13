import subprocess
import time


GATEWAY_URL = str(subprocess.check_output("kubectl get svc -n istio-system | grep -E 'istio-ingress' | awk '{ print $4 }'", universal_newlines=True,shell=True)).rstrip()

subprocess.check_output("istioctl create -f ../nginmesh-0.2.12/samples/kubernetes/route-rule-reviews-50-v3.yaml > /dev/null 2>&1",universal_newlines=True,shell=True)

time.sleep(5)


v1_count=0
v2_count=0
v3_count=0
total_count = 0

while total_count < 10:
    output = str(subprocess.check_output("curl -s -w 'Status_Code=%{http_code}\n' http://"+GATEWAY_URL+"/productpage", universal_newlines=True,shell=True)).rstrip()

    if 'Status_Code=200' in output and 'color="black"' not in output and 'color="red"' not in output:
       # print("V1 Starless 'is' here!")
        total_count += 1
        v1_count+=1

    elif 'Status_Code=200' in output and 'color="black"' in output:
     #   print("V2 Black 'is' here!")
        total_count += 1
        v2_count+=1
    elif 'Status_Code=200' in output and 'color="red"' in output:
     #   print("V3 Red 'is' here!")
        total_count += 1
        v3_count+=1
    else:
        print("App does not work!")
        total_count += 1

if  v1_count>0 and v2_count==0 and v3_count>0:
    print("Route all to V1 and V3 Test -- Passed")
    print("| V1 Hit=",v1_count,"| V2 Hit=",v2_count," | V3 Hit=",v3_count," | Total Hit=",total_count," |")
elif v1_count==0:
    print("App V1 does not work!")
elif v2_count>0:
    print("Route does not work!")
elif v3_count==0:
    print("App V3 does not work!")

output2 = str(subprocess.check_output("wrk -t1 -c10 -d1s http://"+GATEWAY_URL+"/productpage | grep -E 'Requests|Transfer|requests|responses'", universal_newlines=True,shell=True)).rstrip()
print(output2)

subprocess.check_output("istioctl delete -f ../nginmesh-0.2.12/samples/kubernetes/route-rule-reviews-50-v3.yaml > /dev/null 2>&1",universal_newlines=True,shell=True)

