function Get-SystemSchedule {
    <#
        .SYNOPSIS
            This function fetches a CacheRefreshPlan from a Power BI report.

        .DESCRIPTION
            This function fetches a CacheRefreshPlan from a Power BI report.

        .PARAMETER ReportServerURL
            #Specify the name of the ReportServerURL.

        .PARAMETER Credential
            Specify the credentials to use when connecting to the Report Server.

        .PARAMETER ErrorFile
            Specify the path to save the exceptions in the file.

        .EXAMPLE
            Get-SystemSchedule -ReportServerURL "http://localhost/ReportServer" -Credential -ErrorFile "C:\Temp\Error_20231003.txt"
            Description
            -----------
            
        .LINK
            
    #>
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $true)]
        $ReportServerURL,
        [System.Management.Automation.PSCredential] 
        $Credential,
        $ErrorFile
    )
    Begin {
        $myProxyURI = $ReportServerURL + "/ReportService2010.asmx?wsdl"
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