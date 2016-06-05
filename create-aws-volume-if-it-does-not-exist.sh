#!/bin/bash

#
# Creates and tags an AWS volume if it does not exist
# Requires AWS CLI: https://aws.amazon.com/cli/
#

export AWS_DEFAULT_REGION=ap-southeast-2

AZ=ap-southeast-2c
ENVIRONMENT=Dev
APPLICATION=foo
VOLUME_NAME=foo-files
VOLUME_SIZE=100

#
# Create database volume if it does not already exist
#

VOLUMEID=$(aws ec2 describe-volumes --filter Name=tag-key,Values=Name,Name=tag-value,Values=${VOLUME_NAME} --query 'Volumes[*][].VolumeId' --output text)

if [ "${VOLUMEID}" == "" ]
then
  VOLUMEID=$(aws ec2 create-volume --size $VOLUME_SIZE --availability-zone $AZ --volume-type gp2 --encrypted --query 'VolumeId' --output text)
  if [ $? -eq 0 ]
  then
    echo "Created $VOLUMEID for $VOLUME_NAME"
    aws ec2 create-tags --resources $VOLUMEID --tags Key=Name,Value=$VOLUME_NAME Key=Environment,Value=$ENVIRONMENT Key=Application,Value=$APPLICATION
  else
    echo "Error creating volume $VOLUME_NAME"
    exit $?
  fi
else
  echo "$VOLUME_NAME already exists: $VOLUMEID"
fi

#
# Query and display all volumes for the application
#

aws ec2 --region=ap-southeast-2 describe-volumes \
  --filter Name=tag-key,Values=Application,Name=tag-value,Values=$APPLICATION \
  --query 'Volumes[*][].{VolumeId:VolumeId,Name:(Tags[?Key==`Name`].Value)[0],Size:Size}[]'

# end
