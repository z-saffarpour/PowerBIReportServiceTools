clear-host

$SourceUser = "myUsername"
$SourcePassword= "myPassword"
$SourceReportURI = 'http://abc.local/'

$DestinationUser = "myUsername"
$DestinationPassword= 'myPassword'
$DestinationReportURI = 'http://xyz:local/'

$DownloadPath = 'C:\Temp\Download'
$UploadPath = 'C:\Temp\Upload'
$ErrorPath = 'C:\Temp\'

$myPowerBIReportContentPath = $DownloadPath + '\PowerBIReports'
$myExcelContentPath = $DownloadPath + '\ExcelWorkbooks'
$myResourceContentPath = $DownloadPath + '\ExcelWorkbooks'

$ExportFiles = $true
##--==============================================================================================================
$ScriptRoot = "D:\Source_GitHub\PowerBIReportServiceTools"
$myScriptItems =  Get-ChildItem "$ScriptRoot\Functions" -Recurse -Include *.ps1
foreach ($myScriptItem in $myScriptItems) 
{ 
    $myScriptItem.FullName
    . $myScriptItem.FullName
}
. "$ScriptRoot\Get-AllItemsFromSource.ps1"
. "$ScriptRoot\New-AllItemsToDestination.ps1"
$ErrorFile = $ErrorPath + "\ErrorFile_" + (Get-Date -Format "yyyy-MM-dd_HH-mm-ss") + ".txt"
##--==============================================================================================================
$mySourcePasswordSecure = ConvertTo-SecureString -AsPlainText -Force -String $SourcePassword
[System.Management.Automation.PSCredential]$mySourceCredential = New-Object PSCredential($SourceUser,$mySourcePasswordSecure )
$mySourceReportServiceURI = "$SourceReportURI/ReportServer"
$mySourceReportRestAPIURI = "$SourceReportURI/reports"

Write-Host ('Start All Items From Source' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss')) -ForegroundColor Green

Get-AllItemsFromSource -ReportServiceURI $mySourceReportServiceURI -ReportRestAPIURI $mySourceReportRestAPIURI -Credential $mySourceCredential `
-DownloadPath $DownloadPath `
-PowerBIReportContentPath $myPowerBIReportContentPath `
-ExcelContentPath $myExcelContentPath `
-ResourceContentPath $myResourceContentPath `
-ExportFiles $ExportFiles `
-ErrorFile $ErrorFile `
-Verbose

Write-Host ('end All Items From Source' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss')) -ForegroundColor Green
##--==============================================================================================================
$myDestinationPasswordSecure = ConvertTo-SecureString -AsPlainText -Force -String $DestinationPassword
[System.Management.Automation.PSCredential]$myDestinationCredential = New-Object PSCredential($DestinationUser,$myDestinationPasswordSecure )
$myDestinationReportServiceURI = "$DestinationReportURI/ReportServer"
$myDestinationeReportRestAPIURI = "$DestinationReportURI/reports"

$mySystemPoliciesFile = $DownloadPath + '\System_Policies.json'
$mySystemPolicyJSON = Get-Content -Path $mySystemPoliciesFile -Raw

$mySystemScheduleFile = $DownloadPath + '\System_Schedules.json'
$mySystemScheduleJSON = Get-Content -Path $mySystemScheduleFile -Raw

$myFolderFile = $DownloadPath + '\Folders.json'
$myFolderJSON = Get-Content -Path $myFolderFile -Raw

$myFolderPolicyFile = $DownloadPath + '\Folder_Policies.json'
$myFolderPolicyJSON = Get-Content -Path $myFolderPolicyFile -Raw

$myPBIReportFile = $DownloadPath + '\PowerBIReports.json'
$myPowerBIReportJSON = Get-Content -Path $myPBIReportFile -Raw

$myPBIReportPoliciesFile = $DownloadPath + '\PowerBIReports_Policies.json'
$myPowerReportPolicyJSON = Get-Content -Path $myPBIReportPoliciesFile -Raw

$myPBIReportDataSourcesFile = $DownloadPath + '\PowerBIReports_DataSources.json'
$myPowerReportDataSourceJSON = Get-Content -Path $myPBIReportDataSourcesFile -Raw

$myPBIReportCredentialList = New-Object System.Collections.ArrayList
$myPBIReportCredentialList.Add([PSCustomObject]@{"Username" = "myUsername"; "CredentialUsername" = "myCredentialUsername"; "CredentialPassword" = 'myCredentialPassword'}) | Out-Null
$myPowerReportCredentialJSON = ConvertTo-Json -InputObject $myPBIReportCredentialList -Depth 15

$myPBIReportScheduleFile = $DownloadPath + '\PowerBIReports_Schedule.json'
$myPowerReportScheduleJSON = Get-Content -Path $myPBIReportScheduleFile -Raw

$myReportRowLevelSecurityFile = $DownloadPath + '\PowerBIReports_RowLevelSecurity.json'
$myPowerReportRowLevelSecurityJSON = Get-Content -Path $myReportRowLevelSecurityFile -Raw

$myExcelFile = $DownloadPath + '\ExcelWorkbooks.json'
$myExcelJSON = Get-Content -Path $myExcelFile -Raw

$myResourceFile = $DownloadPath + '\Resources.json'
$myResourceJSON = Get-Content -Path $myResourceFile -Raw

Write-Host ('Start Upload All Items to Destination' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss')) -ForegroundColor Green
New-AllItemsToDestination -ReportServiceURI $myDestinationReportServiceURI -ReportRestAPIURI $myDestinationeReportRestAPIURI -Credential $myDestinationCredential `
-SystemPolicyItemsJSON $mySystemPolicyJSON `
-SystemScheduleItemsJSON $mySystemScheduleJSON `
-FolderItemsJSON $myFolderJSON `
-FolderPolicyItemsJSON $myFolderPolicyJSON `
-PowerBIReportItemsJSON $myPowerBIReportJSON `
-PowerBIReportPolicyItemsJSON $myPowerReportPolicyJSON `
-PowerBIReportDataSourceItemsJSON $myPowerReportDataSourceJSON `
-PowerBIReportCredentialItemsJSON $myPowerReportCredentialJSON `
-PowerBIReportScheduleItemsJSON $myPowerReportScheduleJSON `
-PowerBIReportRowLevelSecurityItemsJSON $myPowerReportRowLevelSecurityJSON `
-ExcelItemsJSON $myExcelJSON `
-ResourceItemsJSON $myResourceJSON `
-PowerBIReportContentPath $myPowerBIReportContentPath `
-ExcelContentPath $myExcelContentPath `
-ResourceContentPath $myResourceContentPath `
-UploadPath $UploadPath `
-ExportFiles $ExportFiles `
-ErrorFile $ErrorFile `
-Verbose
Write-Host ('End Upload All Items to Destination' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss')) -ForegroundColor Green