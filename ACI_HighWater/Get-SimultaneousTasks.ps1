# Requires -Module MOVEit.MIA
# Use `Install-Module -Name MOVEit.MIA` to install if needed
 
# Set for your environment
$hostname    = 'localhost'
$credential  = [pscredential]::new('miadmin', (ConvertTo-SecureString 'Pc7766!!!' -AsPlainText -Force))    

#Ignore SSL/TLS Warnings!  Not good for production.
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }


 
# Get TaskRuns starting top of last hour
$nowHour = Get-Date -Minute 0 -Second 0 -Millisecond 0 
$startTimeStart  = $nowHour.AddHours(-48)
$startTimeEnd    = $nowHour
$intervalSecs = 60

$TimerStart = Get-Date

# Create Interval Table
# it is a holding tank with one entry per interval you are looking at.  So, if you 
# are interested in a day's worth of minutes, there will only ever be 1440 entries in this hashtable.
# But it will keep track of the various things that happen in that interval.  So, if multiple tasks
# Are running in that interval, it will capture that activity.
$TaskRunInterval = @{}

for ($windowStartTime = $startTimeStart;
     $windowStartTime -lt $startTimeEnd; 
     $windowStartTime = $windowStartTime.AddSeconds($intervalSecs)) {
        $windowEndTime = $windowStartTime.AddSeconds($intervalSecs)
        $TaskRunInterval.$windowStartTime = @{WindowStartTime = $windowStartTime; WindowEndTime = $WindowEndTime; TaskRunCount = 0; TaskName = @{}}
     }

$TaskRunsCount = 0
$TaskRunIntervalInsertions = 0

#Get Task Run Data from MIA
#Open connection to MIA server.
Connect-MIAServer -Hostname $hostname -Credential $credential
$TaskRuns = Get-MIAReportTaskRun -StartTimeStart $startTimeStart -StartTimeEnd $startTimeEnd -MaxCount 100000
Disconnect-MIAServer

# Loop over Task Run data
# Adding a an entry for that run in each interval of the day we are reporting on.
foreach($task in $TaskRuns){
    # When did this task start and end?
    $TaskNormalizedStartTime = [datetime]($task.Starttime.SubString(0,16))
    $TaskNormalizedEndTime = [datetime]($task.Endtime.SubString(0,16))
    
    # Put entries into the interval table for each minute this task ran.
    try{
        for ($i = $TaskNormalizedStartTime; $i -le $TaskNormalizedEndTime; $i = $i.AddSeconds($intervalSecs)){
            $TaskName = $task.TaskName
            ($TaskRunInterval.$i.TaskName).$TaskName = 1
            $TaskRunIntervalInsertions++
        }
    } catch {
        Write-Output $Error
    }
    $TaskRunsCount++
}

$ProcessStepTimerEnd = Get-Date

# Print Output
ForEach($hashentry in $TaskRunInterval.GetEnumerator() | Sort-Object -property name){
    Write-Output("$($hashentry.Value.WindowStartTime) $($hashentry.Value.WindowEndTime)  $($hashentry.Value.TaskName.Count) $($hashentry.Value.TaskName.keys -join ' / ')")
}



Write-Output("")
Write-Output("")
Write-Output("Start Time Start: $($startTimeStart)")
Write-Output("Start Time End: $($startTimeEnd)")
Write-Output("Interval Table Size: $($TaskRunInterval.count)")
Write-Output("Task Runs: $($TaskRunsCount)")
Write-Output("Interval Table Updates $($TaskRunIntervalInsertions)")

Write-Output("")
Write-Output("")
# print processing time
$TotalTimerEnd = Get-Date
$TotalTimeDelta = $TotalTimerend - $TimerStart
$ProcessTimeDelta = $ProcessStepTimerend - $TimerStart
write-output "Start Time: $TimerStart"
write-output "Process End Time: $ProcessStepTimerEnd"
write-output "Total End Time: $TotalTimerEnd"
write-output "Process Seconds: $($processtimedelta.TotalSeconds)"
write-output "Total Seconds: $($TotalTimeDelta.TotalSeconds)"
