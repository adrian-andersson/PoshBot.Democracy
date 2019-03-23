function get-activeVote
{

    <#
        .SYNOPSIS
            Get the vote data and return the active vote
            
        .DESCRIPTION
            Get the vote data and return the active vote for the channel id provided

        .PARAMETER channelId
            What channel
            
            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
                2019-03-22 - AA
                    - Initial Script
                    
    #>

    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true)]
        [string]$channel
        
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{
        $voteData = get-voteData

        write-verbose 'Channel data found, checking for validity and active vote'
        if($votedata."$channel".getType().Name -ne 'Hashtable')
        {
            write-verbose 'Channel data not a hashtable, probably corrupt, return $null'
            return
        }

        if(($voteData."$channel") -and ($votedata."$channel".getType().Name -eq 'Hashtable'))
        {
            write-verbose 'Channel available and valid'
            $keys = $voteData."$channel".keys
            $activeVotes = foreach($key in $keys)
            {
                if($votedata."$channel"."$key".isActive -eq $true)
                {
                    $votedata."$channel"."$key"
                }
            }
            $activeVotesCount = $($activeVotes|measure-object).count
            if($activeVotesCount -gt 1)
            {
                write-verbose 'We have undesired multiple votes, return the most recent'
                return $($activeVotes|sort-object -property createdDate -Descending|Select-object -First 1)

            }elseIf($activeVotesCount -eq 1)
            {
                write-verbose 'We have the desired active vote'
                return $activeVotes
            }else{
                write-verbose 'No Active votes for this channel'
                return $null
            }
        }else{
            write-verbose 'Either no channel data or data is corrupt'
            return $null
        }


        $activeVotes = if($votedata."$channel")
        {
            else{
                
            }

        }else{
            write-verbose 'No data for channel'
            return
        }
    }
}