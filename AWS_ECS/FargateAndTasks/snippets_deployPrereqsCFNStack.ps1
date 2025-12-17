## some snippets for CloudFormation stack deployment
#Requires AWS.Tools.CloudFormation

$strCodeGoodnessWorkingDir = "<repoRoot\SomeFolder>"

$strCFNStackName = "Learning-AWSECS-ecs-task-roles"
$strCFNTemplateFilespec = "$strCodeGoodnessWorkingDir\CFN-PrereqsForECSThings.yaml"
$strCFNStackTagsJSONFilespec = "$strCodeGoodnessWorkingDir\cfnStackLevelTags.default.json"

## test and lint CFN template
Test-CFNTemplate -TemplateBody (Get-Content -Path $strCFNTemplateFilespec -Raw)
cfn-lint.exe --template $strCFNTemplateFilespec

## see if stack '$strCFNStackName' exists
$existingStack = Get-CFNStack | Where-Object StackName -eq $strCFNStackName

$hshParamsForStack = @{
    StackName = $strCFNStackName
    TemplateBody = Get-Content -Path $strCFNTemplateFilespec -Raw
    Capability = "CAPABILITY_IAM"
    RoleArn = (Get-IAMRole -RoleName CloudFormationDeployment).Arn
    Tag = Get-Content -Raw $strCFNStackTagsJSONFilespec | ConvertFrom-Json
    OutVariable = "oNewCFNStack"
    Verbose = $true
}

if ($existingStack) {
    Write-Verbose -Verbose "👵 Stack exists, updating stack '$strCFNStackName'"
    Update-CFNStack @hshParamsForStack
} else {
    Write-Verbose -Verbose "👶 Stack does not exist yet, creating new stack '$strCFNStackName'"
    New-CFNStack @hshParamsForStack
}

## wait for the CFN stack deploy to finish
Wait-CFNStack -StackName $strCFNStackName -Timeout (New-TimeSpan -Minutes 5).TotalSeconds

## see some stack resource info
Get-CFNStack -StackName $strCFNStackName | Get-CFNStackResourceSummary | Sort-Object -Property LastUpdatedTimestamp | Select-Object ResourceType, LogicalResourceId, ResourceStatus, LastUpdatedTimestamp, PhysicalResourceId | Format-Table -AutoSize

## get CFN stack events
Get-CFNStack -StackName $strCFNStackName | Get-CFNStackEvent | Sort-Object -Property Timestamp -Descending:$true | Select-Object -First 10 | Format-List | more




## remove the stack
Remove-CFNStack -StackName $strCFNStackName