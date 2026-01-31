echo "In the terminal while running add the instances names (frontend, catalogue, mysql)"
AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0adfe78ec6189cd05"
ZONE_ID="Z03460353RS4GS5RQB39D"
DOMAIN_NAME="believeinyou.fun"
echo "get IP_ss"
#Instance ID flow


# Create EC2
️# AWS returns huge JSON
#--query extracts InstanceId
# --output text removes JSON formatting
# $() stores the value
for instance in $*
do 
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    if [ $instance != "frontend" ]; then 
        IP_Address=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME" # ex-mongodb.daws.fun
        
    else
        IP_Address=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text) 
        RECORD_NAME="$DOMAIN_NAME"
    fi    
    echo "$instance: $IP_Address"
    aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '
  {
    "Comment": "Updating record set.."
    ,"Changes": [{
      "Action"              : "UPSERT"
      ,"ResourceRecordSet"  : {
        "Name"              : "'$RECORD_NAME'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$IP_Address'"
        }]
      }
    }]
  }
  '
done
