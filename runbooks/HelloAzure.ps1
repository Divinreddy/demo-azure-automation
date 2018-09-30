Param
(
    [Parameter (Mandatory= $false)]
    [string] $uriToTest = "https://azure.microsoft.com"
)
#Adapted from: https://gallery.technet.microsoft.com/scriptcenter/Powershell-Script-for-13a551b3
try{ 
    $requestTime = Measure-Command { $testRequest = Invoke-WebRequest -Uri $uriToTest -UseBasicParsing } 
    $result = [PSCustomObject] @{ 
      Time = Get-Date; 
      Uri = $uri; 
      StatusCode = [int] $testRequest.StatusCode; 
      StatusDescription = $testRequest.StatusDescription; 
      ResponseLength = $testRequest.RawContentLength; 
      TimeTakenInMilliseconds =  $requestTime.TotalMilliseconds;  
      } 
    Write-Output $result
  }  
  catch 
  { 
    Write-Error "Check failed with '$_.Exception'"
    throw $_.Exception
  }   
  
