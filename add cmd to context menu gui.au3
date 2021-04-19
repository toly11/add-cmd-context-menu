#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Array.au3>

$form = GUICreate('add cmd to context menu', 447, 197, -1, -1)
GUISetIcon('C:\Program Files\PowerShell\7\assets\Powershell_black.ico', -1)
$button_add = GUICtrlCreateButton('add', 56, 64, 137, 33)
GUICtrlSetFont(-1, 12, 800, 0, 'MS Sans Serif')
$button_remove = GUICtrlCreateButton('remove', 248, 64, 137, 33)
GUICtrlSetFont(-1, 12, 800, 0, 'MS Sans Serif')
$Radio_hebrew = GUICtrlCreateRadio('hebrew', 370, 137, 53, 17)
GUICtrlSetTip(-1, 'display language of context menu enteryes')
$Radio_english = GUICtrlCreateRadio('english', 370, 161, 53, 17)
GUICtrlSetTip(-1, 'display language of context menu enteryes')
GUICtrlCreateGroup('', -99, -99, 1, 1)
$Radio_show = GUICtrlCreateRadio('Show', 22, 137, 49, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetTip(-1, 'show in context menu')
$Radio_hide = GUICtrlCreateRadio('Hide', 22, 161, 49, 17)
GUICtrlSetTip(-1, 'hide from context')
GUICtrlCreateGroup('', -99, -99, 1, 1)

$lang = RegRead('HKCU\Control Panel\Desktop', 'PreferredUILanguages')
If $lang = '' Then
    If @OSLang = '040d' Then
        $lang = 'he-IL'
    EndIf
EndIf

If $lang = 'he-IL' Then
    GUICtrlSetState($Radio_hebrew, $GUI_CHECKED)
Else
    GUICtrlSetState($Radio_english, $GUI_CHECKED)
EndIf

GUISetState(@SW_SHOW)

Global $reg[3]
$reg[0] = 'HKCU\SOFTWARE\Classes\Directory\background\shell\cmd2'
$reg[1] = 'HKCU\SOFTWARE\Classes\Directory\shell\cmd2'
$reg[2] = 'HKCU\SOFTWARE\Classes\Drive\shell\cmd2'

$vbs = @AppDataDir & '\RunCmdAsAdmin.vbs'
$hideItems = False

While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
        Case $button_add
            addForUser()
        Case $button_remove
            deleteFurUser()
    EndSwitch
WEnd

Func addForUser()
    If GUICtrlRead($Radio_hebrew) = 1 Then
        $strCmd = 'פתח כאן שורת פקודה'
        $strCmdAdmin = '‏‏‏‏פתח כאן שורת פקודה כמנהל'
    Else
        $strCmd = 'open cmd here'
        $strCmdAdmin = '‏‏open cmd here as administrator'
    EndIf

    For $l = 0 To 2
        RegWrite($reg[$l], 'SubCommands', 'REG_SZ', '')
        RegWrite($reg[$l], 'MUIVerb', 'REG_SZ', $strCmd)
        RegWrite($reg[$l], 'icon', 'REG_SZ', 'cmd.exe')
        RegWrite($reg[$l] & '\shell\cmd', '', 'REG_SZ', $strCmd)
        RegWrite($reg[$l] & '\shell\cmd', 'NoWorkingDirectory', 'REG_SZ', '')
        RegWrite($reg[$l] & '\shell\cmd', 'NeverDefault', 'REG_SZ', '')
        RegWrite($reg[$l] & '\shell\cmd', 'Icon', 'REG_SZ', 'cmd.exe')
        RegWrite($reg[$l] & '\shell\cmd\command', '', 'REG_SZ', 'cmd.exe /s /k pushd "%V"')
        RegWrite($reg[$l] & '\shell\cmdAdministrator', '', 'REG_SZ', $strCmdAdmin)
        RegWrite($reg[$l] & '\shell\cmdAdministrator', 'NoWorkingDirectory', 'REG_SZ', '')
        RegWrite($reg[$l] & '\shell\cmdAdministrator', 'NeverDefault', 'REG_SZ', '')
        RegWrite($reg[$l] & '\shell\cmdAdministrator', 'Icon', 'REG_SZ', 'cmd.exe')
        RegWrite($reg[$l] & '\shell\cmdAdministrator', 'CommandFlags', 'REG_DWORD', '23')
        RegWrite($reg[$l] & '\shell\cmdAdministrator\command', '', 'REG_SZ', StringFormat('wscript "%s" "%V"', $vbs))
    Next

    If FileExists($vbs) Then FileDelete($vbs)
    FileWrite($vbs, 'Dim Arg, var1' & @CRLF & _
            'Set Arg = WScript.Arguments' & @CRLF & _
            'Set Shell = CreateObject("Shell.Application")' & @CRLF & _
            'Shell.ShellExecute "cmd", "/k pushd " & Arg(0), , "runas", 1')

    If GUICtrlRead($Radio_hide) = 1 Then hideItems()
    If GUICtrlRead($Radio_show) = 1 Then showItems()
EndFunc

Func deleteFurUser()
    For $l = 0 To 2
        RegDelete($reg[$l])
    Next
    FileDelete($vbs)
EndFunc

Func hideItems()
    For $l = 0 To 2
        RegWrite($reg[$l], 'Extended', 'REG_SZ', '')
    Next
EndFunc

Func showItems()
    For $l = 0 To 2
        RegDelete($reg[$l], 'Extended')
    Next
EndFunc
