function New-AllItemsToDestination {
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
        $SystemPolicyItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)] 
        $SystemScheduleItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)] 
        $FolderItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)] 
        $FolderPolicyItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)] 
        $PowerBIReportItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)] 
        $PowerBIReportPolicyItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)] 
        $PowerBIReportDataSourceItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)] 
        $PowerBIReportCredentialItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)] 
        $PowerBIReportScheduleItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)] 
        $PowerBIReportRowLevelSecurityItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)] 
        $PowerBIContentItemsPath,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)] 
        $UploadPath,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)] 
        $ExportFiles,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)] 
        $ErrorFile
    )
    Begin {
        Write-Verbose ('Start getting the system of policies' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        Grant-SystemPolicyItems -ReportServiceURI $ReportServiceURI -Credential $Credential -SystemPolicyItemsJSON $SystemPolicyItemsJSON -ErrorFile $ErrorFile
        Write-Verbose ('end getting the system of policies' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Verbose ('Start getting the system of Schedule' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $mySystemScheduleItems = New-SystemScheduleItems $ReportServiceURI -Credential $Credential -ScheduleItemsJSON $SystemScheduleItemsJSON -ErrorFile $ErrorFile
        Write-Verbose ('end getting the system of Schedule' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $mySystemScheduleFile = $UploadPath + '\System_Schedules.json'
            $mySystemScheduleItems | Out-File $mySystemScheduleFile
        }

        Write-Verbose ('Start getting the folders' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myFolderItems = New-RsFolderItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -FolderItemsJSON $FolderItemsJSON -ErrorFile $ErrorFile
        Write-Verbose ('end getting the folders' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myFolderFile = $UploadPath + '\Folders.json'
            $myFolderItems | Out-File $myFolderFile
        }

        Write-Verbose ('Start getting the Policy of folders' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        Grant-RsFolderPolicyItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -UploadFolderItemsJSON $myFolderItems -FolderPolicyItemsJSON $FolderPolicyItemsJSON -ErrorFile $ErrorFile
        Write-Verbose ('end getting the Policy of folders' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Verbose ('Start getting the reports(PBI)' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myUploadPBIReportItems = New-RsReportContentItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -PowerBIReportItemsJSON $PowerBIReportItemsJSON -PowerBIContentPath $PowerBIContentItemsPath -ErrorFile $ErrorFile
        Write-Verbose ('end getting the names reports(PBI)' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myUploadPBIReportFile = $UploadPath + '\PowerBIReports.json'
            $myUploadPBIReportItems | Out-File $myUploadPBIReportFile
        }

        Write-Verbose ('Start getting the Policy of report' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        Grant-RsReportPolicyItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -UploadPowerBIReportItemsJSON $myUploadPBIReportItems -PowerBIReportPolicyItemsJSON $PowerBIReportPolicyItemsJSON -ErrorFile $ErrorFile
        Write-Verbose ('end getting the Policy of report' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Verbose ('Start getting the DataSource of reports' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        New-RsReportDataSourceItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -UploadPowerBIReportItems $myUploadPBIReportItems -PowerBIReportDataSourceItemsJSON $PowerBIReportDataSourceItemsJSON -PowerBIReportCredentialItemsJSON $PowerBIReportCredentialItemsJSON -ErrorFile $ErrorFile
        Write-Verbose ('end getting the DataSource of reports' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Verbose ('Start getting the Schedule of reports' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        New-RsReportScheduleItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -UploadSystemScheduleItems $myUploadPBIReportItems -PowerBIReportScheduleItemsJSON $PowerBIReportScheduleItemsJSON -ErrorFile $ErrorFile
        Write-Verbose ('end getting the Schedule of reports' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Verbose ('Start getting the RowLevelSecurity of reports' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        New-RsReportRowLevelSecurityItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -UploadPowerBIReportItems $myUploadPBIReportItems -PowerBIReportRowLevelSecurityItemsJSON $PowerBIReportRowLevelSecurityItemsJSON -ErrorFile $ErrorFile
        Write-Verbose ('end getting the RowLevelSecurity of reports' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
    }
}