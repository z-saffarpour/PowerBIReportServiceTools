param 
(
    [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)] 
    $ScriptPath 
)
clear-host
##--==============================================================================================================
#$ScriptRoot = "C:\Source_GitHub\PowerBIReportServiceTools"
$ScriptRoot = $ScriptPath
$ConfigurationFile = ".\Configuration.json"
$myScriptItems = Get-ChildItem "$ScriptRoot\Functions" -Recurse -Include *.ps1
foreach ($myScriptItem in $myScriptItems) { 
    $myScriptItem.FullName
    . $myScriptItem.FullName
}
. "$ScriptRoot\Get-AllItemsFromSource.ps1"
. "$ScriptRoot\New-AllItemsToDestination.ps1"
##--==============================================================================================================
$myConfiguration = Get-Content $ConfigurationFile -Raw | ConvertFrom-Json

$SourceUser = $myConfiguration.SourceUser
$SourcePassword = $myConfiguration.SourcePassword
$SourceReportURI = $myConfiguration.SourceReportURI

$DestinationUser = $myConfiguration.DestinationUser
$DestinationPassword = $myConfiguration.DestinationPassword
$DestinationReportURI = $myConfiguration.DestinationReportURI

$DownloadPath = $myConfiguration.DownloadPath
$UploadPath = $myConfiguration.UploadPath
$ErrorPath = $myConfiguration.ErrorPath
$ExportFiles = $true #$myConfiguration.ExportFiles

if (!(Test-Path -Path $ErrorPath)) {
    New-Item -ItemType Directory -Path $ErrorPath | Out-Null
}

if (!(Test-Path -Path $DownloadPath)) {
    New-Item -ItemType Directory -Path $DownloadPath | Out-Null
}

if (!(Test-Path -Path $UploadPath)) {
    New-Item -ItemType Directory -Path $UploadPath | Out-Null
}

$myPowerBIReportContentPath = $DownloadPath + '\PowerBIReports'
$myExcelContentPath = $DownloadPath + '\ExcelWorkbooks'
$myResourceContentPath = $DownloadPath + '\Resources'
$ErrorFile = $ErrorPath + "\ErrorFile_" + (Get-Date -Format "yyyy-MM-dd_HH-mm-ss") + ".txt"
##--==============================================================================================================
$mySourceReportServerURL = "$SourceReportURI/ReportServer"
$mySourceWebPortalURL = "$SourceReportURI/reports"

$mySourcePasswordSecure = ConvertTo-SecureString -AsPlainText -Force -String $SourcePassword
[System.Management.Automation.PSCredential]$mySourceCredential = New-Object PSCredential($SourceUser, $mySourcePasswordSecure )

Write-Host ('Start All Items From Source' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss')) -ForegroundColor Green

Get-AllItemsFromSource -ReportServerURL $mySourceReportServerURL -WebPortalURL $mySourceWebPortalURL -Credential $mySourceCredential `
    -DownloadPath $DownloadPath `
    -PowerBIReportContentPath $myPowerBIReportContentPath `
    -ExcelContentPath $myExcelContentPath `
    -ResourceContentPath $myResourceContentPath `
    -ExportFiles $ExportFiles `
    -ErrorFile $ErrorFile 

Write-Host ('end All Items From Source' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss')) -ForegroundColor Green
##--==============================================================================================================
$myDestinationReportServerURL = "$DestinationReportURI/ReportServer"
$myDestinationeWebPortalURL = "$DestinationReportURI/reports"

$myDestinationPasswordSecure = ConvertTo-SecureString -AsPlainText -Force -String $DestinationPassword
[System.Management.Automation.PSCredential]$myDestinationCredential = New-Object PSCredential($DestinationUser, $myDestinationPasswordSecure )

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

$myPowerReportCredentialJSON = $myConfiguration.PowerBIReportDataSourceCredential | ConvertTo-Json -Depth 15

$myPBIReportScheduleFile = $DownloadPath + '\PowerBIReports_Schedule.json'
$myPowerReportScheduleJSON = Get-Content -Path $myPBIReportScheduleFile -Raw

$myReportRowLevelSecurityFile = $DownloadPath + '\PowerBIReports_RowLevelSecurity.json'
$myPowerReportRowLevelSecurityJSON = Get-Content -Path $myReportRowLevelSecurityFile -Raw

$myExcelFile = $DownloadPath + '\ExcelWorkbooks.json'
$myExcelJSON = Get-Content -Path $myExcelFile -Raw

$myResourceFile = $DownloadPath + '\Resources.json'
$myResourceJSON = Get-Content -Path $myResourceFile -Raw

Write-Host ('Start Upload All Items to Destination' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss')) -ForegroundColor Green
New-AllItemsToDestination -ReportServerURL $myDestinationReportServerURL -WebPortalURL $myDestinationeWebPortalURL -Credential $myDestinationCredential `
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
    -ErrorFile $ErrorFile 
Write-Host ('End Upload All Items to Destination' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss')) -ForegroundColor Green