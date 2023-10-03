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
        Write-Output ('start of add user to system security' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        Grant-SystemPolicyItems -ReportServiceURI $ReportServiceURI -Credential $Credential -SystemPolicyItemsJSON $SystemPolicyItemsJSON -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of add user to system security' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Output ('start of create the shared schedule' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $mySystemScheduleItems = New-SystemScheduleItems $ReportServiceURI -Credential $Credential -ScheduleItemsJSON $SystemScheduleItemsJSON -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of create the shared schedule' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $mySystemScheduleFile = $UploadPath + '\System_Schedules.json'
            $mySystemScheduleItems | Out-File $mySystemScheduleFile
        }

        Write-Output ('start of create the folder' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myUploadFolderItems = New-RsFolderItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -FolderItemsJSON $FolderItemsJSON -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of create the folder' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myFolderFile = $UploadPath + '\Folders.json'
            $myUploadFolderItems | Out-File $myFolderFile
        }

        Write-Output ('start of add user to folder security list' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        Grant-RsFolderPolicyItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -UploadFolderItemsJSON $myUploadFolderItems -FolderPolicyItemsJSON $FolderPolicyItemsJSON -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of add user to folder security list' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Output ('start of setting the folder Properties' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        Set-RsFolderPropertiesItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -UploadFolderItemsJSON $myUploadFolderItems -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of setting the folder Properties' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Output ('start of upload PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myUploadPBIReportItems = New-RsReportContentItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -PowerBIReportItemsJSON $PowerBIReportItemsJSON -PowerBIReportContentPath $PowerBIReportContentPath -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of upload PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myUploadPBIReportFile = $UploadPath + '\PowerBIReports.json'
            $myUploadPBIReportItems | Out-File $myUploadPBIReportFile
        }

        Write-Output ('start of add user to PBIReport security list' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        Grant-RsReportPolicyItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -UploadPowerBIReportItemsJSON $myUploadPBIReportItems -PowerBIReportPolicyItemsJSON $PowerBIReportPolicyItemsJSON -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of add user to PBIReport security list' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Output ('start of setting the DataSource in PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        New-RsReportDataSourceItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -UploadPowerBIReportItems $myUploadPBIReportItems -PowerBIReportDataSourceItemsJSON $PowerBIReportDataSourceItemsJSON -PowerBIReportCredentialItemsJSON $PowerBIReportCredentialItemsJSON -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of setting the DataSource in PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Output ('start of setting the Schedule in PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        New-RsReportScheduleItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -UploadSystemScheduleItemsJSON $mySystemScheduleItems -PowerBIReportScheduleItemsJSON $PowerBIReportScheduleItemsJSON -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of setting the Schedule in PBIReport' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Output ('start of add user to PBIReport row level security list' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        New-RsReportRowLevelSecurityItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -UploadPowerBIReportItems $myUploadPBIReportItems -PowerBIReportRowLevelSecurityItemsJSON $PowerBIReportRowLevelSecurityItemsJSON -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of add user to PBIReport row level security list' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Output ('start of setting the PBIReport Properties' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        Set-RsReportPropertiesItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -UploadPowerBIReportItems $myUploadPBIReportItems -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of setting the PBIReport Properties' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))

        Write-Output ('start of upload Excel File' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myUploadExcelItems = New-RsExcelContentItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -ExcelItemsJSON $ExcelItemsJSON -ExcelContentPath $ExcelContentPath -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of upload Excel File' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myUploadExcelFile = $UploadPath + '\ExcelWorkbooks.json'
            $myUploadExcelItems | Out-File $myUploadExcelFile
        }

        Write-Output ('start of upload Other File' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        $myUploadResourceItems = New-RsResourceContentItems -ReportRestAPIURI $ReportRestAPIURI -Credential $Credential -ResourceItemsJSON $ResourceItemsJSON -ResourceContentPath $ResourceContentPath -ErrorFile $ErrorFile -Verbose
        Write-Output ('end of upload Other File' + "==>" + (Get-Date -Format 'yyyy-MM-dd hh:mm:ss'))
        if ($ExportFiles) {
            $myUploadResourceFile = $UploadPath + '\Resources.json'
            $myUploadResourceItems | Out-File $myUploadResourceFile
        }
    }
}