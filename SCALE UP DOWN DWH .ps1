<#
    .DESCRIPTION
        To SCALE UP/Down Azure SQL DWH 

    .NOTES
        AUTHOR: Subhendu Majumder 
        LASTEDIT: 24th June 2021
		
	# Need to Import 
		#Az.Accounts 
		#Az.SQL
		#Microsoft.PowerShell.Utility
#>
# PARAM

	$RGName= '<Put your RG name>'
	$ServerName='<Put your Server name>'
	$DWHName='<Put your Data Warehouse name>'
	$TargetSKU = 'DW300c' # Your desired SKU
	
# Authenticate using the Service Account.
	$acn="<Your Credential>" # This Credential must be set in Azure Runbook
    $azureCredential = Get-AutomationPSCredential -Name $acn #To be fired from Automation Account Runbook
    Write-Output "The credentials object $azureCredential"
    #Connect-AzAccount # If directly using in Power Shell.
	Connect-AzAccount -Credential $azureCredential > $null  #To be fired from Automation Account Runbook
    Write-Output "Logging in to Azure..."

# Main Script

try{
	Select-AzSubscription -SubscriptionId <SubScription ID> 
	#Set-AzContext -SubscriptionName "<SubScription Name>"  # This one works as well.

	$DWHObject = Get-AzSqlDatabase -ResourceGroupName $RGName -ServerName $ServerName -DatabaseName $DWHName

	Set-AzSqlDatabase -DatabaseName "MySQLDW" -ServerName "MyServer" -RequestedServiceObjectiveName "DW1000c"
	$CurrentSKU =$DWHObject.CurrentServiceObjectiveName 
	
	if($CurrentSKU  -ne $TargetSKU )
	{
		
		Set-AzSqlDatabase -ResourceGroupName $RGName -DatabaseName $DWHName -ServerName $ServerName -RequestedServiceObjectiveName $TargetSKU

		$mailsubject="$DWHName Scaled Up to $TargetSKU."
		Write-Output("$DWHName Scaled Up to $TargetSKU.")
	}
	elseif ($CurrentSKU -eq $TargetSKU)
	{
		$mailsubject="$DWHName is already upgraded $TargetSKU."
		Write-Output("$DWHName is already upgraded $TargetSKU.")
	}
	else
	{
		$mailsubject="$DWHName Scale up Exception, please Check the Output for Runbook"
		Write-Output("$DWHName Scale up Exception, please Check the Output for Runbook")
	}
}

Catch {

		$mailsubject= "$DWHName Scale up failed, please Check the Output for Runbook"
		Write-Output("$DWHName Scale up failed, please Check the Output for Runbook")
}
	$frommailcred = Get-AutomationPSCredential -Name EmailCred
	$SubMailTo= "subhendu.majumder@outlook.com" 
	$SubMailFrom="subhendu.majumder@outlook.com" # Or Service Email Account 
	$SubMailCc="subhendu.majumder@outlook.com" # Or Leqave Blank
	$SubMailBody="This is an Auto-Generated Message. If you have any questions, then please write it to subhendu.majumder@outlook.com"
	Send-MailMessage -To $SubMailTo -Cc $SubMailCc -Priority High -From $SubMailFrom -Subject $mailsubject -Body $SubMailBody -Credential $frommailcred -SmtpServer 'outlook.office365.com' -UseSsl -Port 587
				



