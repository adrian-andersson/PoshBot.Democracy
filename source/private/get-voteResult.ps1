function get-voteResult
{

    <#
        .SYNOPSIS
            Get a preformated response for the active Vote
            
        .DESCRIPTION
            Get a preformated response for the active Vote

            Return a nice vote tally
            As well as a line-by-line of who chose what
            
        .PARAMETER activeVote
            An active vote hashtable
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:

                2019-03-22 - AA
                    - Initial Script
                    
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
            $groupedResults = $activeVote.votes.values |group-object|select-object Count,Name
            $totalVotes = $($groupedResults.count|measure-object -Sum).sum
            $i = 0
            $totalOptions = $($activeVote.options|measure-object).count
            $voteSummary = while($i -lt $totalOptions)
            {
                $option = $activeVote.options[$i]
                $votes = $($groupedResults|where-object{$_.name -eq $i}).count
                if(!$votes)
                {
                    $votes = 0
                }
                $voters = $activeVote.votes
                [psCustomObject] @{
                    Option = $option
                    Votes = $votes
                    Percent =  $([math]::round($($votes/$totalVotes)*100,0))
                    voters = $($activevote.votes.GetEnumerator()|where-object{$_.value -eq $i}).name
                }

                $i++
            }

            $top = "$($voteSummary | select-object Option,Votes,Percent|format-table|out-string)"

            $bottom = foreach($v in $voteSummary)
            {
                "*$($v.option)*`n--------------------------`n    $($v.voters -join "`n    ")`n`n`n"
            }

            $result = "$top`n$bottom"

            return $result

            
        }else{
            return $null
        }
        
    }
}