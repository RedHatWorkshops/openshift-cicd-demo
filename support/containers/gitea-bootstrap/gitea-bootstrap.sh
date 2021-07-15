#!/bin/bash

#
## This script sets up gitea via curl-ing the API

#
## Variables
gtadmin=gitea-admin
gtpass=openshift
gtuser=developer
gtpass=openshift
hookreponame=welcome-app
eventlistener="http://el-build-listener.welcome-pipeline.svc.cluster.local:8080"
gturl="http://gitea:3000"
#
## Get Token
export TOKEN=$(curl -s -X POST ${gturl}/api/v1/users/${gtadmin}/tokens -u ${gtadmin}:${gtpass} -H "Content-Type: application/json" -d '{"name": "admintoken"}' | jq -r .sha1)

#
## Create User
echo "Creating user: ${gtuser}"
echo "========================"
curl -s -X POST ${gturl}/api/v1/admin/users \
-H "accept: application/json" \
-H "Authorization: token ${TOKEN}" \
-H "Content-Type: application/json" -d \
"{\"email\":\"${gtuser}@example.com\",\"login_name\":\"${gtuser}\",\"must_change_password\":false,\"password\":\"${gtpass}\",\"send_notify\":false,\"username\":\"${gtuser}\"}"

#
## Get User ID
export GTUID=$(curl -s -X GET ${gturl}/api/v1/users/${gtuser} -H "accept: application/json" -H "Authorization: token ${TOKEN}"  | jq -r .id)

#
## Migrate repos
for repo in https://github.com/RedHatWorkshops/welcome-app https://github.com/RedHatWorkshops/welcome-deploy
do
	reponame=$(basename ${repo})
	echo "Migrating Repo - ${reponame}"
	echo "============================"
	curl -s -X POST ${gturl}/api/v1/repos/migrate \
	-H "accept: application/json" \
	-H "Authorization: token ${TOKEN}" \
	-H "Content-Type: application/json" -d \
	"{\"clone_addr\":\"${repo}\",\"description\":\"\",\"issues\":false,\"milestones\":false,\"mirror\":false,\"private\":false,\"repo_name\":\"${reponame}\",\"uid\":${GTUID}}"
done

#
## Create developer token
export DTOKEN=$(curl -s -X POST ${gturl}/api/v1/users/${gtuser}/tokens -u ${gtuser}:${gtpass} -H "Content-Type: application/json" -d '{"name": "develtoken"}' | jq -r .sha1)
#
## Create hook if not there.
echo "Creating Webhook for repo: ${hookreponame}"
echo "===================================="
hookstatus=$(curl -s -X GET "${gturl}/api/v1/repos/${gtuser}/${hookreponame}/hooks?limit=1" -H "accept: application/json" -H "Authorization: token ${TOKEN}" | grep -c ${eventlistener})
if [[ ${hookstatus} -gt 0 ]]; then
	echo "Hook already created, skipping"
else
	curl -s -X POST ${gturl}/api/v1/repos/${gtuser}/${hookreponame}/hooks \
	-H "accept: application/json" \
	-H "Authorization: token ${DTOKEN}" \
	-H "Content-Type: application/json" -d \
	"{\"active\":true,\"branch_filter\":\"main\",\"config\":{\"content_type\":\"json\",\"url\":\"${eventlistener}\",\"http_method\":\"post\"},\"events\":[\"push\"],\"type\":\"gitea\"}"
fi

##
## TODO: Check everything we've done and "fail out" if none of the steps were performed.
## for now, we'll exit 0 here in a "best effort" bootstrap; since it _should be_ harmless
## to run this again.
exit 0
##
##
