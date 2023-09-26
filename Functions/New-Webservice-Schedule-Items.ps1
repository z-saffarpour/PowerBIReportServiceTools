function New-SystemScheduleItems { 
    
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ReportServiceURI,
        [System.Management.Automation.PSCredential] 
        $Credential,
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ScheduleItemsJSON,
        $ErrorFile
    )
    Begin {
        try {
            $myProxyURI = $ReportServiceURI + "/ReportService2010.asmx?wsdl"
            $myScheduleItems = $ScheduleItemsJSON | ConvertFrom-Json
            if ($null -ne $Credential) {
                $myProxy = New-WebServiceProxy -Class 'NewRS' -Namespace 'NewRS' -Uri $myProxyURI -Credential $Credential -Verbose:$false
            }
            else {
                $myProxy = New-WebServiceProxy -Class 'NewRS' -Namespace 'NewRS' -Uri $myProxyURI -UseDefaultCredential -Verbose:$false
            }
            $myScheduleList = $myProxy.ListSchedules([System.Management.Automation.Language.NullString]::Value)
            $myScheduleResult = @()
            foreach ($myScheduleItem in $myScheduleItems) {
                $myName = $myScheduleItem.Name
                if (!($myScheduleList | Where-Object { $_.Name -eq $myName })) {
                    $myScheduleDefinition = New-Object "NewRS.ScheduleDefinition" 
                    if ($null -ne $myScheduleItem.MinuteInterval) {
                        $myScheduleDefinition.Item = New-Object "NewRS.MinuteRecurrence"
                        $myScheduleDefinition.Item.MinutesInterval = $myScheduleItem.MinuteInterval
                    }
                    elseif ($null -ne $myScheduleItem.DailyInterval) {
                        $myScheduleDefinition.Item = New-Object "NewRS.DailyRecurrence"
                        $myScheduleDefinition.Item.DaysInterval = $myScheduleItem.DailyInterval
                    }
                    elseif ($null -ne $myScheduleItem.WeeklyInterval) {
                        $myScheduleDefinition.Item = New-Object "NewRS.WeeklyRecurrence"
                        $myScheduleDefinition.Item.WeeklyInterval = $myScheduleItem.WeeklyInterval
                    }
                    elseif ($null -ne $myScheduleItem.MonthlyInterval) {
                        $myScheduleDefinition.Item = New-Object "NewRS.MonthlyRecurrence"
                        $myScheduleDefinition.Item.MonthlyInterval = $myScheduleItem.MonthlyInterval
                    }
                    elseif ($null -ne $myScheduleItem.MonthlyDOWInterval) {
                        $myScheduleDefinition.Item = New-Object "NewRS.MonthlyDOWRecurrence"
                        $myScheduleDefinition.Item.MonthlyDOWInterval = $myScheduleItem.MonthlyDOWInterval
                    }
                    $myScheduleDefinition.StartDateTime = [datetime]($myScheduleItem.StartDateTime)
                    $mySiteUrl = [System.Management.Automation.Language.NullString]::Value

                    $myScheduleID = $myProxy.CreateSchedule($myName, $myScheduleDefinition, $mySiteUrl)

                    $myScheduleResult += [PSCustomObject]@{
                        "ScheduleID"         = $myScheduleItem.ScheduleID;
                        "Name"               = $myScheduleItem.Name;
                        "Description"        = $myScheduleItem.Description;
                        "ScheduleStateName"  = $myScheduleItem.ScheduleStateName;
                        "StartDateTime"      = $myScheduleItem.StartDateTime;
                        "MinuteInterval"     = $myScheduleItem.MinuteInterval;
                        "DailyInterval"      = $myScheduleItem.DailyInterval;
                        "WeeklyInterval"     = $myScheduleItem.WeeklyInterval;
                        "MonthlyInterval"    = $myScheduleItem.MonthlyInterval;
                        "MonthlyDOWInterval" = $myScheduleItem.MonthlyDOWInterval;
                        "ScheduleID_New"     = $myScheduleID;
                    }
                }
            }

            $myResultJSON = $myScheduleResult | ConvertTo-Json -Depth 15
            return , $myResultJSON
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : New-SystemScheduleItems" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter = ("--" + ("==" * 70))
                $mySpliter >> $ErrorFile 
            }
        }
    }
}