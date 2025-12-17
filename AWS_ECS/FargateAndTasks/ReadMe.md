# Some Fargate Learning Activities
From the AWS-provided tutorial https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_AWSCLI_Fargate.html

## Some Details, Commands
Some of the things from the walkthrough

- Register task definition using JSON file: `aws ecs register-task-definition --cli-input-json file://fargateTaskDefinition.json --task-role-arn ((Get-CFNStack -StackName $strCFNStackName).Outputs | where OutputKey -eq TaskRoleArn).OutputValue --profile $StoredAWSCredentials`
- Create a Service in a private subnet:
    ```PowerShell
    aws ecs create-service --cluster fargate-cluster --service-name cool-fargate-service --task-definition coolguy-fargate:1 --desired-count 1 --launch-type "FARGATE" --network-configuration ("awsvpcConfiguration={{subnets=[{0}],securityGroups=[{1}]}}" -f (($arrSomeSubnets = Get-EC2Subnet -Filter @{Name = "tag:Type"; Values = "Private"}).SubnetId -join ','), (Get-EC2SecurityGroup -Filter @{Name = "group-name"; Values = "default"}, @{Name = "vpc-id"; Values = $arrSomeSubnets.VpcId}).GroupId) --enable-execute-command
    ```
- Get the ECS service for the cluster: `(Get-ECSClusterDetail -Cluster fargate-cluster).Clusters | Get-ECSClusterService -Cluster {$_.ClusterName}`
- Describe the running service:
    ```PowerShell
    (Write-Output fargate-cluster -PipelineVariable oThisClusterName | Get-ECSClusterService -Cluster {$oThisClusterName} | Get-ECSService -Service {$_} -Cluster {$oThisClusterName}).Services

    ## or, statically
    aws ecs describe-services --cluster fargate-cluster --services cool-fargate-service
    ```
- See the Task details
    ```PowerShell
    ## tasks themselves
    (Write-Output fargate-cluster -PipelineVariable oThisClusterName | Get-ECSTaskList -Cluster {$oThisClusterName} | Get-ECSTaskDetail -Task {$_} -Cluster {$oThisClusterName}).Tasks

    ## get managed agents
    (Write-Output fargate-cluster -PipelineVariable oThisClusterName | Get-ECSTaskList -Cluster {$oThisClusterName} | Get-ECSTaskDetail -Task {$_} -Cluster {$oThisClusterName}).Tasks.Containers.ManagedAgents
    ```
- Launch interactive shell in container
    ```PowerShell
    ## need the Session Manager plugin (https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)
    #    can install on Windows with winget via: Find-WinGetPackage -Id Amazon.SessionManagerPlugin | Install-WinGetPackage
    ## Invoke-ECSCommand -Interactive seems to only return the session -- not clear yet how to leverage that session..
    (Write-Output fargate-cluster -PipelineVariable oThisClusterName | Get-ECSTaskList -Cluster {$oThisClusterName} | Get-ECSTaskDetail -Task {$_} -Cluster {$oThisClusterName}).Tasks | Invoke-ECSCommand -Command /bin/sh -Interactive:$true -Task {$_.TaskArn} -Cluster {$_.ClusterArn} -Container {$_.Containers.Name} -OutVariable oThisECSCommandOutput

    ## or, via the AWS CLI
    aws ecs execute-command --cluster fargate-cluster --task (Write-Output fargate-cluster -PipelineVariable oThisClusterName | Get-ECSTaskList -Cluster {$oThisClusterName} | Get-ECSTaskDetail -Task {$_} -Cluster {$oThisClusterName}).Tasks.TaskArn --container fargate-app --interactive --command "/bin/sh"
    ```
