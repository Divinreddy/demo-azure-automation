workflow ConnectToAzureARM-Workflow
{
	param (
    [Parameter(Mandatory=$false)]
    [String]
    $connectionName = "AzureRunAsConnection"
        )
	try
	{
	    # Get the connection "AzureRunAsConnection "
	    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         
	
	    Write-Verbose "Logging in to Azure..."
	    Add-AzureRmAccount `
	        -ServicePrincipal `
	        -TenantId $servicePrincipalConnection.TenantId `
	        -ApplicationId $servicePrincipalConnection.ApplicationId `
	        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
			
	}
	catch {
	    if (!$servicePrincipalConnection)
	    {
	        $ErrorMessage = "Connection $connectionName not found."
	        throw $ErrorMessage
	    } else{
	        Write-Error -Message $_.Exception
	        throw $_.Exception
	    }
	}
}