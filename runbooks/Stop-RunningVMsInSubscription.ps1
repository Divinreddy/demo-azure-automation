workflow Stop-RunningVMsInSubscription
{
	param (
		[Parameter(Mandatory=$true)]
	    [String]
	    $subscriptionName	
	)
	
	Write-Verbose "Connecting to Azure ARM."
	ConnectoToAzureARM-Workflow 
	Select-AzureRMSubscription -subscriptionName $subscriptionName
	
	$jobResults =@()

	#Get all ARM resources from all resource groups
	$vmsToStop = Find-AzureRMResource -ResourceType 'Microsoft.Compute/virtualMachines'
	
	foreach ($vm in $vmsToStop) {
	
		#Add Checkpoint so the runbook can be resumed if it stops.  
		Checkpoint-Workflow
		#Re-authenticate to Azure after possible workflow resume.
		Write-Verbose "Connecting to Azure ARM."
		ConnectoToAzureARM-Workflow
		Select-AzureRMSubscription -subscriptionName $subscriptionName
	
	    if ($vm.Tags -ne $null -and $vm.Tags.Contains('AlwaysOn') -and $vm.Tags['AlwaysOn'].ToLower() -eq "true" ) {
			Write-Verbose "VM $($vm.Name) in RG $($vm.ResourceGroupName) was tagged with AlwaysOn=true. It will be ignored."
	        $result = New-Object PSCustomObject -Property @{"Name" = $vm.Name; "ResourceGroupName" = $vm.ResourceGroupName; "Status" = "Ignored"}
	    }
	    else {
	        #Get the current status of the VM. Due to status not being available at the list level we have to query again for each VM.
			if ((get-azurermvm -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Status).Statuses.Code.Contains("PowerState/deallocated") -eq $true)
			{
				Write-Verbose "VM $($vm.Name) detected in RG $($vm.ResourceGroupName) was not running."
				
				$result = New-Object PSCustomObject -Property @{"Name" = $vm.Name; "ResourceGroupName" = $vm.ResourceGroupName; "Status" = "AlreadyStopped"} 
			}
			else {
				Write-Verbose "VM $($vm.Name) detected in RG $($vm.ResourceGroupName), attempting to shutdown. " 
						
				Stop-AzureRMVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -Force
				Write-Verbose "VM $($vm.Name) shutdown."
					
				$result = New-Object PSCustomObject -Property @{"Name" = $vm.Name; "ResourceGroupName" = $vm.ResourceGroupName; "Status" = "Stopped"} 
			}
	    }
	    $jobResults += $result
	}
	
	Write-Output $jobResults
}