function save-activeVote
{

    <#
        .SYNOPSIS
            Take an active vote, match it to all the vote data, update it, then save it out to the file
            
        .DESCRIPTION
            Take an active vote, match it to all the vote data, update it, then save it out to the file

        .PARAMETER activeVote
            An active vote hashtable

            
        .NOTES
            Author: Adrian Andersson
            
            
            Changelog:
                2019-03-22 - AA
                    - Initial Script
                    
        .COMPONENT
            What cmdlet does this script live in
    #>

    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true)]
        [hashtable]$activeVote
    )
    begin{
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
        
    }
    
    process{

        $voteData = get-voteData

        $channel = $activeVote.channel
        $voteId = $activeVote.id
        if($voteData."$channel"."$voteid")
        {
            $voteData."$channel"."$voteid" = $activeVote
            save-voteData $voteData
            return $true
        }else{
            return $false
        }

    }
    
}