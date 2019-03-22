function get-voteCloseStatus
{

    <#
        .SYNOPSIS
            Simple description
            
        .DESCRIPTION
            Detailed Description
            
        .PARAMETER param1
            What is it, why do you want it
            
        ------------
        .EXAMPLE
            verb-noun param1
            
            #### DESCRIPTION
            Line by line of what this example will do
            
            
            #### OUTPUT
            Copy of the output of this line
            
            
            
        .NOTES
            Author: Adrian Andersson
            Last-Edit-Date: yyyy-mm-dd
            
            
            Changelog:
                yyyy-mm-dd - AA
                    
                    - Changed x for y
                    
        .COMPONENT
            What cmdlet does this script live in
    #>

    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true,Position=0)]
        [hashtable]$activeVote
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{
        write-verbose 'Check we have valid voteData'
        

        if($activeVote)
        {
            $results = $activeVote.votes.values |group-object|select-object Count,Name
            $totalVotes = $($results.count|measure-object -Sum).sum
            if($totalVotes -le 0)
            {
                return $null
            }
            $i = 0
            $optionCount = $($activeVote.options|measure-object).Count
            $result = while($i -le $optionCount)
            {
                $option = $activeVote.options[$i]
                $resultItem = $result|where-object {$_.name -eq $option}
                [psCustomObject]@{
                    optionNo = $i
                    option = $option
                    votes = $resultItem.count
                    percent = $([math]::round($($resultItem.count/$totalVotes)*100,0))

                }
            }

            return $result
        }else{
            return $null
        }
        
    }
}