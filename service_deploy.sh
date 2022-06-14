#!/bin/bash
START_TIME=`date +%s%N | cut -b1-13`
./service_down.sh
sleep 5
./service_up.sh
END_TIME=`date +%s%N | cut -b1-13`
echo "Fim do deploy..."
echo "{\"eventType\": \"CUSTOM_DEPLOYMENT\", \"start\":\"$START_TIME\", \"end\":\"$END_TIME\", \"timeoutMinutes\": 0, \"attachRules\": {\"tagRule\": [ { \"meTypes\": [ \"SERVICE\" ], \"tags\": [ { \"context\": \"CONTEXTLESS\", \"key\": \"ruby_server\" } ] } ] }, \"source\": \"CONTROL-M\"}" 
curl https://XXXXXX.live.dynatrace.com/api/v1/events -H 'Authorization: Api-token XXXXX' -H 'Content-Type: application/json' -d "{\"eventType\": \"CUSTOM_DEPLOYMENT\", \"start\":\"$START_TIME\", \"end\":\"$END_TIME\", \"timeoutMinutes\": 0, \"attachRules\": {\"tagRule\": [ { \"meTypes\": [ \"SERVICE\" ], \"tags\": [ { \"context\": \"CONTEXTLESS\", \"key\": \"ruby_server\" } ] } ] }, \"source\": \"CONTROL-M\", \"deploymentName\":\"MY_CONTROL_M_JOB\", \"deploymentVersion\":\"1.0\"}" 
curl https://XXXXXX.live.dynatrace.com/api/v1/events -H 'Authorization: Api-token XXXXXX' -H 'Content-Type: application/json' -d "{\"eventType\": \"CUSTOM_DEPLOYMENT\", \"start\":\"$START_TIME\", \"end\":\"$END_TIME\", \"timeoutMinutes\": 0, \"attachRules\": {\"tagRule\": [ { \"meTypes\": [ \"SERVICE\" ], \"tags\": [ { \"context\": \"CONTEXTLESS\", \"key\": \"lab_node\" } ] } ] }, \"source\": \"CONTROL-M\", \"deploymentName\":\"MY_CONTROL_M_JOB\", \"deploymentVersion\":\"1.0\"}" 
