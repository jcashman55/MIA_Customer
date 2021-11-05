# Requires -Module MOVEit.MIA$
# Use `Install-Module -Name MOVEit.MIA` to install if needed
 
# Set for your environment
$hostname    = 'localhost'

$credential  = [pscredential]::new('miadmin', (ConvertTo-SecureString 'Pc7766!!!' -AsPlainText -Force))    
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
Connect-MIAServer -Hostname $hostname -Credential $credential
 
# Get TaskRuns starting top of last hour
$startTimeStart  = Get-Date -Hour (Get-Date).AddHours(-10).Hour -Minute 0 -Second 0 -Millisecond 0
$startTimeEnd    = Get-Date
 
$taskRuns = Get-MIAReportTaskRun -StartTimeStart $startTimeStart -StartTimeEnd $startTimeEnd -MaxCount 100000
 
"Analyzing $($taskRuns.Count) Task Run records"
 
# Set the interval to check in seconds
$interval = 60

# Empty array to hold the results
$taskRunIntervals = @()
 
for ($windowStartTime = $startTimeStart; 
     $windowStartTime -lt $startTimeEnd; 
     $windowStartTime = $windowStartTime.AddSeconds($interval)) {
       
    #Determine the windowEndTime based on the interval    
    $windowEndTime = $windowStartTime.AddSeconds($interval).AddMilliseconds(-1)
    
    # See https://stackoverflow.com/questions/325933/determine-whether-two-date-ranges-overlap
    $taskRunsThisInterval = $taskRuns | Where-Object {
        $windowStartTime -le $_.EndTime -and
        $windowEndTime -ge $_.StartTime
    }
 
    if ($taskRunsThisInterval.Count -gt 0) {        
        $taskRunIntervals += ([PSCustomObject]@{
            WindowStartTime = $windowStartTime
            WindowEndTime = $windowEndTime
            TaskRunCount = $taskRunsThisInterval.Count
            TaskRuns = $taskRunsThisInterval
        }) 
    }
}
 