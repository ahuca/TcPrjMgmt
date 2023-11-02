$MsgFilterSrc = @"
// https://learn.microsoft.com/en-us/previous-versions/visualstudio/visual-studio-2010/ms228772(v=vs.100)

using System;
using System.Runtime.InteropServices;

public class MessageFilter : IOleMessageFilter
{
    //
    // IOleMessageFilter functions.
    // Handle incoming thread requests.
    int IOleMessageFilter.HandleInComingCall(int dwCallType,
        IntPtr hTaskCaller, int dwTickCount, IntPtr
            lpInterfaceInfo)
    {
        //Return the flag SERVERCALL_ISHANDLED.
        return 0;
    }

    // Thread call was rejected, so try again.
    int IOleMessageFilter.RetryRejectedCall(IntPtr
        hTaskCallee, int dwTickCount, int dwRejectType)
    {
        if (dwRejectType == 2)
            // flag = SERVERCALL_RETRYLATER.
            // Retry the thread call immediately if return >=0 & 
            // <100.
            return 99;
        // Too busy; cancel call.
        return -1;
    }

    int IOleMessageFilter.MessagePending(IntPtr hTaskCallee,
        int dwTickCount, int dwPendingType)
    {
        //Return the flag PENDINGMSG_WAITDEFPROCESS.
        return 2;
    }
    // Class containing the IOleMessageFilter
    // thread error-handling functions.

    // Start the filter.
    public static void Register()
    {
        IOleMessageFilter newFilter = new MessageFilter();
        IOleMessageFilter oldFilter = null;
        CoRegisterMessageFilter(newFilter, out oldFilter);
    }

    // Done with the filter, close it.
    public static void Revoke()
    {
        IOleMessageFilter oldFilter = null;
        CoRegisterMessageFilter(null, out oldFilter);
    }

    // Implement the IOleMessageFilter interface.
    [DllImport("Ole32.dll")]
    private static extern int
        CoRegisterMessageFilter(IOleMessageFilter newFilter, out
            IOleMessageFilter oldFilter);
}

[ComImport]
[Guid("00000016-0000-0000-C000-000000000046")]
[InterfaceTypeAttribute(ComInterfaceType.InterfaceIsIUnknown)]
internal interface IOleMessageFilter
{
    [PreserveSig]
    int HandleInComingCall(
        int dwCallType,
        IntPtr hTaskCaller,
        int dwTickCount,
        IntPtr lpInterfaceInfo);

    [PreserveSig]
    int RetryRejectedCall(
        IntPtr hTaskCallee,
        int dwTickCount,
        int dwRejectType);

    [PreserveSig]
    int MessagePending(
        IntPtr hTaskCallee,
        int dwTickCount,
        int dwPendingType);
}
"@

$PlcProjectExtension = ".plcproj"
$ProgIdList = @(
    "TcXaeShell.DTE.15.0", # TcXaeShell (VS2017)
    "VisualStudio.DTE.16.0", # VS2019
    "VisualStudio.DTE.15.0", # VS2017
    "VisualStudio.DTE.14.0", # VS2015
    "VisualStudio.DTE.12.0" # VS2013
)

Add-Type -TypeDefinition $MsgFilterSrc

$public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($import in @($public + $private)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $public.Basename