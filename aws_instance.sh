OWNER_DEFAULT="PABLON@SYNOPSYS.COM"
DEFAULT_ALERT_VERSION="6.4.4"
for arg in "$@"
do
    case $arg in
        -c|--create)
        CREATE=1
        shift # Remove --initialize from processing
        ;;
        -h|--help)
        echo "-c --create          creates a new instance"
        echo "-d --delete          deletes selected instance"
        echo "-a --alert           [optional. Default latest] alert version"
        echo "-v --version         [optional. Default latest] Hub version"
        echo "-n --name            name of the instance to manage"
        echo "-k --key-name        key name on AWS to access instance"
        echo "-o --owner           [optional. Default $OWNER_DEFAULT] OWNER tag for resources"
        echo "-i --instance-size   [optional. Default c5.4xlarge] AWS size for the instance"
        echo "-e --ebs-size        [optional. Defaul 100 GB] size for the EBS volume"
        shift # Remove --initialize from processing
        ;;
        -n=*|--name=*)
        INSTANCE_NAME="${arg#*=}"
        shift # Remove --cache= from processing
        ;;
        -v=*|--version=*)
        HUB_VERSION="release/${arg#*=}"
        shift # Remove --cache= from processing
        ;;
        -a=*|--alert=*)
        ALERT_VERSION="${arg#*=}"
        ALERT=1
        shift # Remove --cache= from processing
        ;;
        -o=*|--owner=*)
        OWNER_TAG="${arg#*=}"
        shift # Remove --cache= from processing
        ;;
        -i=*|--instance-size=*)
        INSTANCE_SIZE="${arg#*=}"
        shift # Remove --cache= from processing
        ;;
        -k=*|--key-name=*)
        KEY_NAME="${arg#*=}"
        shift # Remove --cache= from processing
        ;;
        -e=*|--ebs-size=*)
        EBS_SIZE="${arg#*=}"
        shift # Remove --cache= from processing
        ;;
        -d|--delete)
        DELETE=1
        shift # Remove argument name from processing
        ;;
        *)
        OTHER_ARGUMENTS+=("$1")
        shift # Remove generic argument from processing
        ;;
    esac
done

delete_instance() {
echo "we will delete $1"
aws ec2 terminate-instances --instance-ids $1
}

check_key_name() {
return $(aws ec2 describe-key-pairs --key-names bds_pablo | jq '. | length')
}

check_instance_name () {
return $(aws ec2 describe-instances --filters "Name=tag:Name,Values=$1" | jq '.Reservations | length')
}

check_instance_creation () {
  status="not_started"
  while [ "$status" != "running" ]; do status=$(aws ec2 describe-instances --instance-ids $1| jq .Reservations[].Instances[].State.Name | sed -e 's/^"//' -e 's/"$//'); echo "deployment state" $status; sleep 2; done;

}

check_instance_readiness () {
  state="nook"
  while [ "$state" != "ok" ]; do state=$(aws ec2 describe-instance-status --instance-ids $1 | jq .InstanceStatuses[].InstanceStatus.Status |  sed -e 's/^"//' -e 's/"$//'); echo "Check status" $state; sleep 15; done;

}

initialize_instance (){
  aws ssm send-command --instance-ids $1 --document-name "AWS-RunShellScript" --parameters commands="sudo wget https://raw.githubusercontent.com/pabloalmarza/automatedchub/main/initialize_instance.sh -O /tmp/initialize_instance.sh" | grep null
  aws ssm send-command --instance-ids $1 --document-name "AWS-RunShellScript" --parameters commands="sudo chmod 777 /tmp/initialize_instance.sh" | grep null
  aws ssm send-command --instance-ids $1 --document-name "AWS-RunShellScript" --parameters commands="/tmp/initialize_instance.sh -a=$ALERT_VERSION -v=$HUB_VERSION" | grep null

}


create_instance () {

if [ "$KEY_NAME" == "" ]
then
  echo "please select a key to create instance"
else
  check_key_name $KEY_NAME
  if [ "$?" == "1" ]
  then
    if [ "$HUB_VERSION" == "" ]
    then
      HUB_VERSION="master"
    fi
    if [ "$ALERT_VERSION" == "" ]
    then
      ALERT_VERSION=$DEFAULT_ALERT_VERSION
    fi
    if [ "$INSTANCE_SIZE" == "" ]
    then
      INSTANCE_SIZE="c5.4xlarge"
    fi
    if [ "$OWNER_TAG" == "" ]
    then
      OWNER_TAG=$OWNER_DEFAULT
    fi
    if [ "$EBS_SIZE" == "" ]
    then
      EBS_SIZE="100"
    fi
    output_status=$(aws ec2 run-instances --image-id ami-0742b4e673072066f --instance-type $INSTANCE_SIZE --iam-instance-profile Arn="arn:aws:iam::493166774317:instance-profile/EnablesEC2ToAccessSystemsManagerRole" --key-name $KEY_NAME --security-groups HUB_PUBLIC_SG --block-device-mappings '[{"DeviceName": "/dev/sdh","Ebs": {"VolumeSize": '$EBS_SIZE'}}]' --tag-specifications 'ResourceType=instance,Tags=[{Key=OWNER,Value='$OWNER_TAG'}, {Key=Name,Value='$INSTANCE_NAME'}]' 'ResourceType=volume,Tags=[{Key=OWNER,Value='$OWNER_TAG'}, {Key=Name,Value=VOLUME_'$INSTANCE_NAME'}]')
    instanceid=$(echo $output_status | jq .Instances[].InstanceId | sed -e 's/^"//' -e 's/"$//')
    check_instance_creation $instanceid
    check_instance_readiness $instanceid
    initialize_instance $instanceid
    echo "log into ec2-user@"$(aws ec2 describe-instances --instance-ids $instanceid | jq .Reservations[].Instances[].PublicDnsName | sed -e 's/^"//' -e 's/"$//') "to review hub status"


  else
    echo "ERROR: key $KEY_NAME does not exist"
  fi
fi
}


if [ "$CREATE" == "1" ] && [ "$DELETE" == "1" ]
then
  echo "Only one option can be selected"
fi

if [ "$CREATE" != "1" ] && [ "$DELETE" != "1" ]
then
  echo "Please select one option"
fi

if [ "$CREATE" == "1" ] && [ "$DELETE" != "1" ]
then
  if [ "$INSTANCE_NAME" != "" ]
  then
    check_instance_name $INSTANCE_NAME
    if [ "$?" != "0" ]
    then
      echo "Instance name $INSTANCE_NAME already exists"
    else
      create_instance
    fi
  else
    echo "please selete the instance name to be created"
  fi
fi

if [ "$CREATE" != "1" ] && [ "$DELETE" == "1" ]
then
  if [ "$INSTANCE_NAME" != "" ]
  then
    check_instance_name $INSTANCE_NAME
    if [ "$?" != "0" ]
    then
      instanceid=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME" | jq .Reservations[].Instances[].InstanceId | sed -e 's/^"//' -e 's/"$//')
      delete_instance $instanceid

    else
      echo "Instance name $INSTANCE_NAME does not exist"
    fi
  else
    echo "please selete the intance name to be deleted"
  fi
fi
