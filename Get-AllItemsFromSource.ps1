function Get-AllItemsFromSource {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]  
        $ReportServiceURI,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ReportRestAPIURI,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $DownloadPath ,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ErrorFile,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        $ExportFiles
    )
    Begin {
        Write-Verbose ('Start getting the system of policies' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $mySystemPolicyItems = Get-SystemPolicy -ReportServiceURI $ReportServiceURI -Credential $Credential -ErrorFile $ErrorFile
        Write-Verbose ('end getting the system of policies' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $mySystemPoliciesFile = $DownloadPath + '\System_Policies.json'
            $mySystemPolicyItems | Out-File $mySystemPoliciesFile
        }

        Write-Verbose ('Start getting the system of Schedule' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $mySystemScheduleItems = Get-SystemSchedule -ReportServiceURI $ReportServiceURI -Credential $Credential -ErrorFile $ErrorFile
        Write-Verbose ('end getting the system of Schedule' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $mySystemScheduleFile = $DownloadPath + '\System_Schedules.json'
            $mySystemScheduleItems | Out-File $mySystemScheduleFile
        }

        Write-Verbose ('Start getting the folders' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myFolderItems = Get-RSFolder -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -ErrorFile $ErrorFile
        Write-Verbose ('end getting the folders' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myFolderFile = $DownloadPath + '\Folders.json'
            $myFolderItems | Out-File $myFolderFile
        }

        Write-Verbose ('Start getting the Policy of folders' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myFolderPolicyItems = Get-RsFolderPolicyItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -FolderItemsJSON $myFolderItems -ErrorFile $ErrorFile
        Write-Verbose ('end getting the Policy of folders' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myFolderPolicyFile = $DownloadPath + '\Folder_Policies.json'
            $myFolderPolicyItems | Out-File $myFolderPolicyFile
        }

        Write-Verbose ('Start getting the reports(PBI)' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myPBIReportItems = Get-RsPBIReport -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -ErrorFile $ErrorFile
        Write-Verbose ('end getting the names reports(PBI)' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myPBIReportFile = $DownloadPath + '\PowerBIReports.json'
            $myPBIReportItems | Out-File $myPBIReportFile
        }

        Write-Verbose ('Start getting the Policy of report' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myPBIReportPolicyItems = Get-RsPBIReportPolicyItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -PowerBIReportItemsJSON $myPBIReportItems -ErrorFile $ErrorFile
        Write-Verbose ('end getting the Policy of report' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myPBIReportPolicyFile = $DownloadPath + '\PowerBIReports_Policies.json'
            $myPBIReportPolicyItems | Out-File $myPBIReportPolicyFile
        }

        Write-Verbose ('Start getting the DataSource of reports' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myPBIReportDataSourceItems = Get-RsPBIReportDataSourceItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -PowerBIReportItemsJSON $myPBIReportItems -ErrorFile $ErrorFile
        Write-Verbose ('end getting the DataSource of reports' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myPBIReportDataSourceFile = $DownloadPath + '\PowerBIReports_DataSources.json'
            $myPBIReportDataSourceItems | Out-File $myPBIReportDataSourceFile
        }

        Write-Verbose ('Start getting the RowLevelSecurity of reports' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myPBIReportRowLevelSecurityItems = Get-RsPBIReportRLSItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -PowerBIReportItemsJSON $myPBIReportItems -ErrorFile $ErrorFile
        Write-Verbose ('end getting the RowLevelSecurity of reports' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myReportRowLevelSecurityFile = $DownloadPath + '\PowerBIReports_RowLevelSecurity.json'
            $myPBIReportRowLevelSecurityItems | Out-File $myReportRowLevelSecurityFile
        }

        Write-Verbose ('Start getting the Schedule of reports' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myPBIReportScheduleItems = Get-RsPBIReportScheduleItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -PowerBIReportItemsJSON $myPBIReportItems -ErrorFile $ErrorFile
        Write-Verbose ('end getting the Schedule of reports' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myPBIReportScheduleFile = $DownloadPath + '\PowerBIReports_Schedule.json'
            $myPBIReportScheduleItems | Out-File $myPBIReportScheduleFile
        }

        Write-Verbose ('Start getting the PowerBI Content of reports' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myPBIContentPath = $DownloadPath + '\PowerBIReports'
        Get-RsPBIContentItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -PowerBIReportItemsJSON $myPBIReportItems -PowerBIContentPath $myPBIContentPath -ErrorFile $ErrorFile
        Write-Verbose ('end getting the PowerBI Content of reports' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
    }
}