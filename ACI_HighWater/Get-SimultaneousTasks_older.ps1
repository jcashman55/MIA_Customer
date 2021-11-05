# Requires -Module MOVEit.MIA
# Use `Install-Module -Name MOVEit.MIA` to install if needed
 
# Set for your environment
$hostname    = 'localhost'
$credential  = [pscredential]::new('miadmin', (ConvertTo-SecureString 'Pc7766!!!' -AsPlainText -Force))    
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
Connect-MIAServer -Hostname $hostname -Credential $credential
 
# Get TaskRuns starting top of last hour
# How many hours to go back?
#$startTimeStart  = Get-Date -Hour (Get-Date).AddHours(-24).Hour -Minute 0 -Second 0 -Millisecond 0
$nowHour = Get-Date -Minute 0 -Second 0 -Millisecond 0 
$startTimeStart  = $nowHour.AddHours(-24)
$startTimeEnd    = $nowHour
 

 


$taskRuns = Get-MIAReportTaskRun -StartTimeStart $startTimeStart -StartTimeEnd $startTimeEnd -MaxCount 100000
 
"Analyzing $($taskRuns.Count) Task Run records"
 
# Set the interval to check in seconds
$interval = 60
 
# Empty array to hold the results
$taskRunIntervals = @()
$taskRunsThisInterval = @()
 
#~1,500 rows since yesterday at 5pm
#intervals during that time: = ~ 21 hours time 60 min = 1,260
# So, scanning (1,500 * 1,260) = ~ 1.9 million rows.  ouch.

$timerstart = get-date

for ($windowStartTime = $startTimeStart; 
     $windowStartTime -lt $startTimeEnd; 
     $windowStartTime = $windowStartTime.AddSeconds($interval)) {
       
    #Determine the windowEndTime based on the interval  
    # IS THIS adding an extra minute?  NO  
    #$windowEndTime = $windowStartTime.AddSeconds($interval).AddMilliseconds(-1)
    $windowEndTime = $windowStartTime.AddSeconds($interval)
    
    # See https://stackoverflow.com/questions/325933/determine-whether-two-date-ranges-overlap
    # this must take whatever interval we are on from the for loop, and query for those items that are in that interval
    # so, we will do a full scan of $taskruns (I think) for each interval.
    $taskRunsThisInterval = @($taskRuns | Where-Object {
        $windowStartTime -lt $_.EndTime -and
        $windowEndTime -ge $_.StartTime
        }
    ) 
 
    # not recording the first entry. Why?  Because, on first attempt, I don't yet have
    # anything in the object, so it is 0, and I'm excluding 0.
    # how to get first one? NO, this should work.  Why not?
    #if ($taskRunsThisInterval.Count -gt 0) {        
        $taskRunIntervals += ([PSCustomObject]@{
            WindowStartTime = $windowStartTime
            WindowEndTime = $windowEndTime
            TaskRunCount = $taskRunsThisInterval.Count
            TaskRuns = $taskRunsThisInterval
        }) 
    #}
}

$processStepTimerEnd = get-date
 
# Display the results
$taskRunIntervals | Format-Table -Wrap -Property @(
     @{
        Name ='Date'
        E = {$_.WindowStartTime}
        FormatString = 'yyyy-MM-dd'
        Width = 12
    },
    @{
        Name ='Start'
        E = {$_.WindowStartTime}
        FormatString = 'T'
        Alignment = 'right'
        Width = 13
    },
    @{
        Name ='End'
        E = {$_.WindowEndTime}
        FormatString = 'T'
        Alignment = 'right'
        Width = 13
    },
    @{
        N='Count'
        E={$_.TaskRunCount}
        Alignment = 'right'
        Width = 5
    },
    @{
        Name = 'TaskRuns'
        Expression = {$_.TaskRuns.TaskName -join ', '}
    }
)

# print processing time
$totalTimerEnd = get-date
$totalTimeDelta = $totaltimerend - $timerstart
$processTimeDelta = $processStepTimerend - $timerstart
write-output "Start Time: $timerstart"
write-output "Process End Time: $processStepTimerEnd"
write-output "Total End Time: $totaltimerend"
write-output "Process Seconds: $($processtimedelta.TotalSeconds)"
write-output "Total Seconds: $($totaltimedelta.TotalSeconds)"
Disconnect-MIAServer