function Get-SystemSchedule {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ReportServiceURI,
        [System.Management.Automation.PSCredential] 
        $Credential,
        $ErrorFile
    )
    Begin {
        $myProxyURI = $ReportServiceURI + "/ReportService2010.asmx?wsdl"
        $myScheduleItems = New-Object System.Collections.ArrayList
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            if ($null -ne $Credential) {
                $myProxy = New-WebServiceProxy  -Class 'GetRS' -Namespace 'GetRS' -Uri $myProxyURI -Credential $Credential -Verbose:$false
            }
            else {
                $myProxy = New-WebServiceProxy  -Class 'GetRS' -Namespace 'GetRS' -Uri $myProxyURI -UseDefaultCredential -Verbose:$false
            }
            $myListScheduleItems = $myProxy.ListSchedules([System.Management.Automation.Language.NullString]::Value)
            foreach ($myListScheduleItem in $myListScheduleItems) {
                $myScheduleItem = [PSCustomObject]@{
                    "ScheduleID"         = $myListScheduleItem.ScheduleID;
                    "Name"               = $myListScheduleItem.Name;
                    "Description"        = $myListScheduleItem.Description;
                    "ScheduleStateName"  = $myListScheduleItem.ScheduleStateName;
                    "StartDateTime"      = $myListScheduleItem.Definition.StartDateTime.ToString("yyyy/MM/dd hh:mm:ss");
                    "MinuteInterval"     = $myListScheduleItem.Definition.Item.MinutesInterval
                    "DailyInterval"      = $myListScheduleItem.Definition.Item.DaysInterval
                    "WeeklyInterval"     = $myListScheduleItem.Definition.Item.WeeklyInterval
                    "MonthlyInterval"    = $myListScheduleItem.Definition.Item.MonthlyInterval
                    "MonthlyDOWInterval" = $myListScheduleItem.Definition.Item.MonthlyDOWInterval
                }
                $myScheduleItems.Add($myScheduleItem) | Out-Null
            }
            $myResultJSON = $myScheduleItems | ConvertTo-Json -Depth 15 
            return , $myResultJSON
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-SystemSchedule" >> $ErrorFile
                $_ >> $ErrorFile
                $mySpliter >> $ErrorFile 
            }
        }
    }
}