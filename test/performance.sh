echo Performance test with 1 thread 10 connection in 3 seconds:
wrk -t1 -c10 -d3s http://${GATEWAY_URL}/productpage | grep -E 'Requests|Transfer|requests|responses'
