function Get-SystemPolicy {
    <#
        .SYNOPSIS
            This function retrieves access policies to Power BI Report Server Instance from users/groups.

        .DESCRIPTION
            This function retrieves access policies to Power BI Report Server Instance from users/groups.

        .PARAMETER ReportServerURL
            #Specify the name of the ReportServerURL.

        .PARAMETER Credential
            Specify the credentials to use when connecting to the Report Server.

        .PARAMETER ErrorFile
            Specify the path to save the exceptions in the file.

        .EXAMPLE
            Get-SystemPolicy -ReportServerURL "http://localhost/ReportServer" -Credential -ErrorFile "C:\Temp\Error_20231003.txt"
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
        $mySystemPolicyItems = New-Object System.Collections.ArrayList
        $mySpliter = ("--" + ("==" * 70))
    }
    Process {
        try {
            if ($null -ne $Credential) {
                $myProxy = New-WebServiceProxy -Class 'GetRS' -Namespace 'GetRS' -Uri $myProxyURI -Credential $Credential -Verbose:$false
            }
            else {
                $myProxy = New-WebServiceProxy -Class 'GetRS' -Namespace 'GetRS' -Uri $myProxyURI -UseDefaultCredential -Verbose:$false
            }
            $mySystemPolicies = $myProxy.GetSystemPolicies()
            foreach ($mySystemPolicyItem in $mySystemPolicies) {
                $myRoleItems = New-Object System.Collections.ArrayList
                foreach ($myRole in $mySystemPolicyItem.Roles) {
                    $myRoleItems.Add([PSCustomObject]@{"Name" = $myRole.Name; "Description" = $myRole.Description; }) | Out-Null
                }
                $mySystemPolicyItems.Add([PSCustomObject]@{"GroupUserName" = $mySystemPolicyItem.GroupUserName; "Roles" = $myRoleItems; }) | Out-Null
            }
            $myResultJSON = $mySystemPolicyItems | ConvertTo-Json -Depth 15
            return , $myResultJSON  
        }
        catch {
            if ($null -ne $ErrorFile -and $ErrorFile.Length -gt 0) {
                "Function : Get-SystemPolicy" >> $ErrorFile
                $_ >> $ErrorFile  
                $mySpliter >> $ErrorFile 
            }
        }
    }
}