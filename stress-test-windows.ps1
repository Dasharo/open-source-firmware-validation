$numCores = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors

foreach ($loopnumber in 1..$numCores){
    $start_time = Get-Date
    Start-Job -ScriptBlock{
    $result = 7
        while (Get-Date) -lt ($start_time.AddMinutes(60)) { # Parametrize stress length
            # Is this really the best operation to stress the system?
            $result = $result * $result
    }
}

Wait-Job *
Clear-Host
Receive-Job *
Remove-Job *
