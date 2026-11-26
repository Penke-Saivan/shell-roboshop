echo "In the terminal while running add the instances names (frontend, catalogue, mysql)"
#AMI_ID="ami-09c813fb71547fc4f"
AMI_ID="ami-0055977a6e828a4f4"
SG_ID="sg-0adfe78ec6189cd05"
ZONE_ID="Z03460353RS4GS5RQB39D"
DOMAIN_NAME="believeinyou.fun"
echo "get IP_ss"
#Instance_ID flow
# Create EC2
️# AWS returns huge JSON
#--query extracts InstanceId
# --output text removes JSON formatting
# $() stores the value

# Find instance with given ID- IP_Address
# Get full metadata
# Extract only PublicIpAddress
# Return plain text
# Store inside variable

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

#run-instances_response-sample
{
    "Instances": [
        {
            "AmiLaunchIndex": 0,
            "ImageId": "ami-0abcdef1234567890",
            "InstanceId": "i-1231231230abcdef0",
            "InstanceType": "t2.micro",
            "KeyName": "MyKeyPair",
            "LaunchTime": "2018-05-10T08:05:20.000Z",
            "Monitoring": {
                "State": "disabled"
            },
            "Placement": {
                "AvailabilityZone": "us-west-2a",
                "GroupName": "",
                "Tenancy": "default"
            },
            "PrivateDnsName": "ip-10-0-0-157.us-west-2.compute.internal",
            "PrivateIpAddress": "10.0.0.157",
            "ProductCodes": [],
            "PublicDnsName": "",
            "State": {
                "Code": 0,
                "Name": "pending"
            },
            "StateTransitionReason": "",
            "SubnetId": "subnet-04a636d18e83cfacb",
            "VpcId": "vpc-1234567890abcdef0",
            "Architecture": "x86_64",
            "BlockDeviceMappings": [],
            "ClientToken": "",
            "EbsOptimized": false,
            "Hypervisor": "xen",
            "NetworkInterfaces": [
                {
                    "Attachment": {
                        "AttachTime": "2018-05-10T08:05:20.000Z",
                        "AttachmentId": "eni-attach-0e325c07e928a0405",
                        "DeleteOnTermination": true,
                        "DeviceIndex": 0,
                        "Status": "attaching"
                    },
                    "Description": "",
                    "Groups": [
                        {
                            "GroupName": "MySecurityGroup",
                            "GroupId": "sg-0598c7d356eba48d7"
                        }
                    ],
                    "Ipv6Addresses": [],
                    "MacAddress": "0a:ab:58:e0:67:e2",
                    "NetworkInterfaceId": "eni-0c0a29997760baee7",
                    "OwnerId": "123456789012",
                    "PrivateDnsName": "ip-10-0-0-157.us-west-2.compute.internal",
                    "PrivateIpAddress": "10.0.0.157",
                    "PrivateIpAddresses": [
                        {
                            "Primary": true,
                            "PrivateDnsName": "ip-10-0-0-157.us-west-2.compute.internal",
                            "PrivateIpAddress": "10.0.0.157"
                        }
                    ],
                    "SourceDestCheck": true,
                    "Status": "in-use",
                    "SubnetId": "subnet-04a636d18e83cfacb",
                    "VpcId": "vpc-1234567890abcdef0",
                    "InterfaceType": "interface"
                }
            ],
            "RootDeviceName": "/dev/xvda",
            "RootDeviceType": "ebs",
            "SecurityGroups": [
                {
                    "GroupName": "MySecurityGroup",
                    "GroupId": "sg-0598c7d356eba48d7"
                }
            ],
            "SourceDestCheck": true,
            "StateReason": {
                "Code": "pending",
                "Message": "pending"
            },
            "Tags": [],
            "VirtualizationType": "hvm",
            "CpuOptions": {
                "CoreCount": 1,
                "ThreadsPerCore": 1
            },
            "CapacityReservationSpecification": {
                "CapacityReservationPreference": "open"
            },
            "MetadataOptions": {
                "State": "pending",
                "HttpTokens": "optional",
                "HttpPutResponseHopLimit": 1,
                "HttpEndpoint": "enabled"
            }
        }
    ],
    "OwnerId": "123456789012",
    "ReservationId": "r-02a3f596d91211712"
}
