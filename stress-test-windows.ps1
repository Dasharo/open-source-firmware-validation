$numCores = 4

foreach ($loopnumber in 1..$numCores){
    Start-Job -ScriptBlock{
    $result = 1
        foreach ($number in 1..40000000){
            $result = $result * $number
        }
    }
}

Wait-Job *
Clear-Host
Receive-Job *
Remove-Job *
