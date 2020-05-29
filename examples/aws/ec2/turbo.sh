#!/usr/local/bin/bash

################################################################
# Example usage:
# ./turbo.sh -s 'turbonomic.example.com' -u 'administrator' -p 'administrator' --name 'buckley_vm'

# --server | Turbonomic server
server=''
# --user | API username
username=''
# --pass | API password
password=''
# --cookies | Temp file to store cookies in
cookies='./cookies.txt'

# jq filter command for parsing actions
jqfilter='[.[] | select(.actionType==$type and .target[$field]==$id) | .newEntity.displayName] | unique | .[0]'
# --name or --uuid | Turbonomic identifier for looking up the instance action
vmid=''
# do not modify, will be set by --name or --uuid
vmidfield=''
# do not modify, action type to query
actiontype='RIGHT_SIZE'

# terraform variables file
filename='terraform.tfvars'
# terraform variable name
template_var='instance_type'
# template value, to be queried from Turbonomic
template=''
# apply flag
apply=false


while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
      -c|--cookies)
      cookies="$2"
      shift
      shift
      ;;
      -p|--pass)
      password="$2"
      shift
      shift
      ;;
      -s|--server)
      server="$2"
      shift
      shift
      ;;
      -u|--user)
      user="$2"
      shift
      shift
      ;;
      -f|--file)
      filename="$2"
      shift
      shift
      ;;
      --name)
      vmid="$2"
      vmidfield='displayName'
      shift
      shift
      ;;
      --uuid)
      vmid="$2"
      vmidfield='uuid'
      shift
      shift
      ;;
      --var|--variable)
      template_var="$2"
      shift
      shift
      ;;
      --apply)
      apply=true
      shift
      ;;
      *)
      shift
      ;;
  esac
done

# establish a session to Turbonomic
curl -s -c "$cookies" -k "https://${server}/vmturbo/rest/login" -d "username=${username}&password=${password}" 1> /dev/null

# Identify our target template
template=`curl -s -b "$cookies" -k "https://${server}/vmturbo/rest/markets/Market/actions" | jq --arg field "$vmidfield" --arg id "$vmid" --arg type "$actiontype" "$jqfilter"`

#clean up / clear cookies file
rm -f "$cookies"

# update the terraform vars file
# if running on OS X you should use a gnu compatible sed,
# such as gsed (from homebrew), -i will fail with native OS X sed
sed -E -i "\,^${template_var}[ ]*=,s,\".*\",${template},g" "$filename"

# optionally apply the config
if [ "$apply" = true ]; then
  terraform apply
fi
