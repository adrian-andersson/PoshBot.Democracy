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
            if($activeVote.isActive -eq $true)
            {
                write-verbose 'check the number of votes'
                $count = $activeVote.votes.count
                if($count -ge $activeVote.closeAfter)
                {
                    #we should close
                    return 'shouldClose'
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