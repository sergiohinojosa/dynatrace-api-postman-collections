#!/usr/bin/env bash
# Getting the bash from the environment (we expect 4+)
# You need bash version 4+ to execute this bash since we are using arrays.

# Tenant https://abcd.live.dynatrace.com/
TENANT="https://abcd.live.dynatrace.com"

# Copy the cookies in format cookies="Cookie: key=value; key2=value2; "
# You need SRV, b925d32c & apmsessionid
# A request that don't have those together and match the server values, will reset the apmsessionid and cut the response.
#b925d32c=xx;
cookies="Cookie: SRV=xxx; b925d32c=xxx ; apmsessionid=xxx; "
contentType="Content-Type: application/json"

declare -A spec
spec["env1"]=/rest/v2/rest-api-docs/v1/spec3.json
spec["env2"]=/rest/v2/rest-api-docs/v2/spec3.json
spec["conf1"]=/rest/v2/rest-api-docs/config/v1/spec3.json

# Another way to initiate arrays
##spec+=( ["key2"]=val2 ["key3"]=val3 )
download_specs(){
    for key in "${!spec[@]}"
      do
      echo "Fetching spec ${key} - $TENANT${spec[${key}]}"
      # echo $key -H "$contentType" -H "$cookies" $TENANT${spec[${key}]}
      curl -s -o specs/$key.json -H "$contentType" -H "$cookies" $TENANT${spec[${key}]}
      result=$?
      # If file size is 0 we assume you are not authorized.
      fileSize=$(wc specs/$key.json | awk '{print $1}')
      if [ 0 -eq $fileSize ];
        then 
        echo "You are not authorized. Check your security Cookies. $cookies"
        exit
      else
        echo "Spec downloaded specs/$key.json $fileSize bytes"  
      fi;
    done
}
parse_specs(){
    for key in "${!spec[@]}"
      do
      sed -i.bak -e 's~'"$TENANT"'~{{tenant}}~' -e 's~securityScheme~_securityScheme~' specs/$key.json
    done
    # Clean up
    rm specs/*.bak
    echo "Specs have been parameterized"
}

download_specs
parse_specs

echo "Now import the specs in Postman and add the Authorization at Collection level"
exit
# Api-Token