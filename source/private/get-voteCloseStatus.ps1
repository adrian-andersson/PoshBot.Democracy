function get-voteCloseStatus
{

    <#
        .SYNOPSIS
            Figure out what the close state should be
            I.E. if the closeAfter is set, should we close it
            
        .DESCRIPTION
            Figure out what the close state should be
            I.E. if the closeAfter is set, should we close it

        .PARAMETER ActiveVote
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
            if($activeVote.isActive -eq $true)
            {
                write-verbose 'check the number of votes'
                $count = $activeVote.votes.count
                if($count -ge $activeVote.closeAfter -and $activeVote.closeAfter -ne 0)
                {
                    #we should close
                    return 'shouldClose'
                }elseIf($activeVote.closeAfter -eq 0){
                    return 'manualClose'
                }else{
                    return 'active'
                }
            }else{
                return 'closed'
            }
        }else{
            return 'error'
        }
        
    }
}