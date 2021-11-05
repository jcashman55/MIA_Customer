# Helper Functions

function Time-It {
    [cmdletbinding()]param(
        [DateTime]$StartTime = (get-date),
        [datetime]$PreviousTime = (get-date),
        [bool]$Print = $true
    )
    
    $Now = Get-Date
    $TotalTimeDelta = $Now - $StartTime
    $CurrentTimeDelta = $Now - $PreviousTime
    
    if($Print){
        write-host "Start Time: $StartTime"
        write-host "Previous Step Start Time: $PreviousTime"
        write-host "Step End Time: $Now"
        write-host "Process Seconds: $($CurrentTimeDelta.TotalSeconds)"
        write-host "Total Seconds: $($TotalTimeDelta.TotalSeconds)"
    }
    return $PreviousTime
}

Set-Alias ti Time-It
Export-ModuleMember -Function Time-It -Alias ti
