#Requires -Module MOVEit.MIA
# Set for your environment
$hostname = 'tperri-mia.local'
$username = 'miadmin'
# Set the number of hours to analyze
$numHours = 24
# Set the number of seconds per interval (default 60 = 1 min intervals)
$intervalSecs = 60
# Connect to MIAServer
try {
    Connect-MIAServer -Hostname $hostname -Credential (Get-Credential -Username $username -Message 'Enter password')
}
catch {
    Write-Error $PSItem
    break
}
# Get the start time starting top of the hour from $numHours prior
$startTimeStart = Get-Date -Date ((Get-Date).AddHours(-$numHours)) -Minute 0 -Second 0 -Millisecond 0
# Create an array to hold the results
$results = [Object[]]::new($numHours)

# Process in batches of 1 hour
# Using a ForEach-Object so we can pipe the output to Format-Table
0..($numHours - 1) | ForEach-Object {
    # Determine the start and end for this batch
    $batchStartTime = $startTimeStart.AddHours($_)
    $batchEndTime = $batchStartTime.AddHours(1).AddMilliseconds(-1)
    # Retrieve the taskruns for this batch
    $predicate = 'StartTime=le={0:yyyy-MM-ddTHH:mm:ss};EndTime=ge={1:yyyy-MM-ddTHH:mm:ss}' -f $batchEndTime, $batchStartTime
    $taskRunsThisBatch = @(Get-MIAReportTaskRun -Predicate $predicate -OrderBy 'StartTime')
    # Determine the number if intervals for this batch
    $numIntervals = (New-TimeSpan -Start $batchStartTime -End $batchEndTime).TotalSeconds / $intervalSecs
    # Get the taskruns for this interval and save in the $results array
    $results[$_] = foreach ($interval in (0..($numIntervals - 1))) {
        $intervalStartTime = $batchStartTime.AddSeconds($interval * $intervalSecs)
        $intervalEndTime = $intervalStartTime.AddSeconds($intervalSecs).AddMilliseconds(-1)
        $taskRunsThisInterval = @($taskRunsThisBatch.where( {
            [DateTime]::Parse($_.StartTime) -le $intervalEndTime -and
            [DateTime]::Parse($_.EndTime) -ge $intervalStartTime
        }))
        # Write to Output
        [PSCustomObject]@{
            IntervalStartTime = $intervalStartTime
            IntervalEndTime = $intervalEndTime
            TaskRunCount = $taskRunsThisInterval.Count
            TaskRuns = $taskRunsThisInterval
        }
    }
    # Write the results for this batch so users start getting immmediate results.
    Write-Output $results[$_]


