#!/bin/bash

# A bash script to update a Cloudflare DNS A record with the external IP of the instance
# Needs the DNS record pre-created on Cloudflare

# Cloudflare zone is the zone which holds the record
dnsrecord=dont_touch_dnsrecord
zoneid=dont_touch_zoneid

## Cloudflare authentication details
## keep these private
cloudflare_auth_key=dont_touch_api

# Get the current external IP address
ip=$(curl -s -X GET https://api.ipify.org)

#echo "Current IP is $ip"

if host $dnsrecord 1.1.1.1 | grep "has address" | grep "$ip"; then
#  echo "$dnsrecord is currently set to $ip; no changes needed"
  exit
fi

# if the dns record needs updating

# get the dns record id
dnsrecordid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records?type=A&name=$dnsrecord" \
  -H "Authorization: Bearer $cloudflare_auth_key" \
  -H "Content-Type: application/json" | jq -r  '{"result"}[] | .[0] | .id')

# update the record
curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records/$dnsrecordid" \
  -H "Authorization: Bearer $cloudflare_auth_key" \
  -H "Content-Type: application/json" \
  --data "{\"type\":\"A\",\"name\":\"$dnsrecord\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":true}" | jq
