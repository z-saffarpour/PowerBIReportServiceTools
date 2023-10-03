function Get-AllItemsFromSource {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]  
        $ReportServerURL,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $WebPortalURL,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $DownloadPath ,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $PowerBIReportContentPath,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ExcelContentPath,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ResourceContentPath,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [bool]
        $ExportFiles,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ErrorFile
    )
    Process {
        Write-Output ('start of get the System policies' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $mySystemPolicyItems = Get-SystemPolicy -ReportServerURL $ReportServerURL -Credential $Credential -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of get the system of policies' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $mySystemPoliciesFile = $DownloadPath + '\System_Policies.json'
            $mySystemPolicyItems | Out-File $mySystemPoliciesFile
        }

        Write-Output ('start of getting the Shared schedule' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $mySystemScheduleItems = Get-SystemSchedule -ReportServerURL $ReportServerURL -Credential $Credential -ErrorFile $ErrorFile -Verbose
        Write-Output ('end getting the Shared schedule' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $mySystemScheduleFile = $DownloadPath + '\System_Schedules.json'
            $mySystemScheduleItems | Out-File $mySystemScheduleFile
        }

        Write-Output ('start of get the list of folder' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myFolderItems = Get-RSFolder -WebPortalURL $WebPortalURL -Credential $Credential -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of get the list of folder' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myFolderFile = $DownloadPath + '\Folders.json'
            $myFolderItems | Out-File $myFolderFile
        }

        Write-Output ('start of get the list of security by folder' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myFolderPolicyItems = Get-RsFolderPolicyItems -WebPortalURL $WebPortalURL -Credential $Credential -FolderItemsJSON $myFolderItems -ErrorFile $ErrorFile -Verbose
        Write-Output ('end  get the list of security by folder' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myFolderPolicyFile = $DownloadPath + '\Folder_Policies.json'
            $myFolderPolicyItems | Out-File $myFolderPolicyFile
        }

        Write-Output ('start of get the list of PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myPBIReportItems = Get-RsPBIReport -WebPortalURL $WebPortalURL -Credential $Credential -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of get the list of PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myPBIReportFile = $DownloadPath + '\PowerBIReports.json'
            $myPBIReportItems | Out-File $myPBIReportFile
        }

        Write-Output ('start of get the list of security by PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myPBIReportPolicyItems = Get-RsPBIReportPolicyItems -WebPortalURL $WebPortalURL -Credential $Credential -PowerBIReportItemsJSON $myPBIReportItems -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of get the list of security by PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myPBIReportPolicyFile = $DownloadPath + '\PowerBIReports_Policies.json'
            $myPBIReportPolicyItems | Out-File $myPBIReportPolicyFile
        }

        Write-Output ('start of get the list of data source by PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myPBIReportDataSourceItems = Get-RsPBIReportDataSourceItems -WebPortalURL $WebPortalURL -Credential $Credential -PowerBIReportItemsJSON $myPBIReportItems -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of get the list of data source by PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myPBIReportDataSourceFile = $DownloadPath + '\PowerBIReports_DataSources.json'
            $myPBIReportDataSourceItems | Out-File $myPBIReportDataSourceFile
        }

        Write-Output ('start of get the list of row level security by PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myPBIReportRowLevelSecurityItems = Get-RsPBIReportRLSItems -WebPortalURL $WebPortalURL -Credential $Credential -PowerBIReportItemsJSON $myPBIReportItems -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of get the list of row level security by PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myReportRowLevelSecurityFile = $DownloadPath + '\PowerBIReports_RowLevelSecurity.json'
            $myPBIReportRowLevelSecurityItems | Out-File $myReportRowLevelSecurityFile
        }

        Write-Output ('start of get the list of schedule by PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myPBIReportScheduleItems = Get-RsPBIReportScheduleItems -WebPortalURL $WebPortalURL -Credential $Credential -PowerBIReportItemsJSON $myPBIReportItems -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of get the list of schedule by PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myPBIReportScheduleFile = $DownloadPath + '\PowerBIReports_Schedule.json'
            $myPBIReportScheduleItems | Out-File $myPBIReportScheduleFile
        }

        Write-Output ('start of download PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        Get-RsPBIReportContentItems -WebPortalURL $WebPortalURL -Credential $Credential -PowerBIReportItemsJSON $myPBIReportItems -PowerBIReportContentPath $PowerBIReportContentPath -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of download PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Output ('start of get the list of excel file' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myExcelItems = Get-RsExcel -WebPortalURL $WebPortalURL -Credential $Credential -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of get the list of excel file' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myExcelFile = $DownloadPath + '\ExcelWorkbooks.json'
            $myExcelItems | Out-File $myExcelFile
        }

        Write-Output ('start of download excel file' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        Get-RsExcelContentItems -WebPortalURL $WebPortalURL -Credential $mySourceCredential -ExcelItemsJSON $myExcelItems -ExcelContentPath $ExcelContentPath -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of download excel file' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        
        Write-Output ('start of get the list of other file' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myResourceItems = Get-RsResource -WebPortalURL $WebPortalURL -Credential $Credential -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of get the list of other file' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myResourceFile = $DownloadPath + '\Resources.json'
            $myResourceItems | Out-File $myResourceFile
        }

        Write-Output ('start of download other file' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        Get-RsResourceContentItems -WebPortalURL $WebPortalURL -Credential $mySourceCredential -ResourceItemsJSON $myResourceItems -ResourceContentPath $ResourceContentPath -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of download other file' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
    }
}