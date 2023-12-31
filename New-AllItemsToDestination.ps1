function New-AllItemsToDestination {
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
        $ExcelItemsJSON,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)] 
        $ResourceItemsJSON,        
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)] 
        $PowerBIReportContentPath,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)] 
        $ExcelContentPath,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)] 
        $ResourceContentPath,        
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)] 
        $UploadPath,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)] 
        $ExportFiles,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)] 
        $ErrorFile
        #$ParentPath
    )
    Process {    
        Write-Output ('start of get the system information' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $mySystemItems = Get-RsSystem -WebPortalURL $WebPortalURL -Credential $Credential -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of get the system information' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $mySystemFile = $UploadPath + '\System.json'
            $mySystemItems | Out-File $mySystemFile
        }

        Write-Output ('start of add user to system security' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        Grant-SystemPolicyItems -ReportServerURL $ReportServerURL -Credential $Credential -SystemPolicyItemsJSON $SystemPolicyItemsJSON -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of add user to system security' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Output ('start of create the shared schedule' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $mySystemScheduleItems = New-SystemScheduleItems -ReportServerURL $ReportServerURL -Credential $Credential -ScheduleItemsJSON $SystemScheduleItemsJSON -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of create the shared schedule' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $mySystemScheduleFile = $UploadPath + '\System_Schedules.json'
            $mySystemScheduleItems | Out-File $mySystemScheduleFile
        }

        Write-Output ('start of create the folder' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myUploadFolderItems = New-RsFolderItems -WebPortalURL $WebPortalURL -Credential $Credential -FolderItemsJSON $FolderItemsJSON -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of create the folder' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myFolderFile = $UploadPath + '\Folders.json'
            $myUploadFolderItems | Out-File $myFolderFile
        }

        Write-Output ('start of add user to folder security list' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        Grant-RsFolderPolicyItems -WebPortalURL $WebPortalURL -Credential $Credential -UploadFolderItemsJSON $myUploadFolderItems -FolderPolicyItemsJSON $FolderPolicyItemsJSON -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of add user to folder security list' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Output ('start of setting the folder Properties' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        Set-RsFolderPropertiesItems -WebPortalURL $WebPortalURL -Credential $Credential -UploadFolderItemsJSON $myUploadFolderItems -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of setting the folder Properties' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Output ('start of upload PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myUploadPBIReportItems = New-RsReportContentItems -WebPortalURL $WebPortalURL -Credential $Credential -PowerBIReportItemsJSON $PowerBIReportItemsJSON -PowerBIReportContentPath $PowerBIReportContentPath -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of upload PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myUploadPBIReportFile = $UploadPath + '\PowerBIReports.json'
            $myUploadPBIReportItems | Out-File $myUploadPBIReportFile
        }

        Write-Output ('start of add user to PBIReport security list' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        Grant-RsReportPolicyItems -WebPortalURL $WebPortalURL -Credential $Credential -UploadPowerBIReportItemsJSON $myUploadPBIReportItems -PowerBIReportPolicyItemsJSON $PowerBIReportPolicyItemsJSON -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of add user to PBIReport security list' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Output ('start of setting the DataSource in PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        New-RsReportDataSourceItems -WebPortalURL $WebPortalURL -Credential $Credential -UploadPowerBIReportItems $myUploadPBIReportItems -PowerBIReportDataSourceItemsJSON $PowerBIReportDataSourceItemsJSON -PowerBIReportCredentialItemsJSON $PowerBIReportCredentialItemsJSON -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of setting the DataSource in PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Output ('start of setting the Schedule in PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        New-RsReportScheduleItems -WebPortalURL $WebPortalURL -Credential $Credential -UploadSystemScheduleItemsJSON $mySystemScheduleItems -PowerBIReportScheduleItemsJSON $PowerBIReportScheduleItemsJSON -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of setting the Schedule in PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Output ('start of add user to PBIReport row level security list' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        New-RsReportRowLevelSecurityItems -WebPortalURL $WebPortalURL -Credential $Credential -UploadPowerBIReportItems $myUploadPBIReportItems -PowerBIReportRowLevelSecurityItemsJSON $PowerBIReportRowLevelSecurityItemsJSON -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of add user to PBIReport row level security list' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Output ('start of setting the PBIReport Properties' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        Set-RsReportPropertiesItems -WebPortalURL $WebPortalURL -Credential $Credential -UploadPowerBIReportItems $myUploadPBIReportItems -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of setting the PBIReport Properties' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Output ('start of upload Excel File' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myUploadExcelItems = New-RsExcelContentItems -WebPortalURL $WebPortalURL -Credential $Credential -ExcelItemsJSON $ExcelItemsJSON -ExcelContentPath $ExcelContentPath -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of upload Excel File' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myUploadExcelFile = $UploadPath + '\ExcelWorkbooks.json'
            $myUploadExcelItems | Out-File $myUploadExcelFile
        }

        Write-Output ('start of upload Other File' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myUploadResourceItems = New-RsResourceContentItems -WebPortalURL $WebPortalURL -Credential $Credential -ResourceItemsJSON $ResourceItemsJSON -ResourceContentPath $ResourceContentPath -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of upload Other File' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myUploadResourceFile = $UploadPath + '\Resources.json'
            $myUploadResourceItems | Out-File $myUploadResourceFile
        }
    }
}