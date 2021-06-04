#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

$form = GUICreate('add cmd to context menu', 447, 197, -1, -1)
GUISetIcon('icon.ico', -1)
$button_add = GUICtrlCreateButton('add', 56, 64, 137, 33)
GUICtrlSetFont(-1, 12, 800, 0, 'MS Sans Serif')
$button_remove = GUICtrlCreateButton('remove', 248, 64, 137, 33)
GUICtrlSetFont(-1, 12, 800, 0, 'MS Sans Serif')
$Radio_hebrew = GUICtrlCreateRadio('hebrew', 370, 137, 53, 17)
GUICtrlSetTip(-1, 'language of context menu enteryes')
$Radio_english = GUICtrlCreateRadio('english', 370, 161, 53, 17)
GUICtrlSetTip(-1, 'language of context menu enteryes')
GUICtrlCreateGroup('', -99, -99, 1, 1)
$Radio_show = GUICtrlCreateRadio('Show', 22, 137, 49, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetTip(-1, 'Show in context menu')
$Radio_hide = GUICtrlCreateRadio('Hide', 22, 161, 49, 17)
GUICtrlSetTip(-1, 'Hide from context menu' & @CRLF & '(shift + right click to display)')
GUICtrlCreateGroup('', -99, -99, 1, 1)

$lang = RegRead('HKCU\Control Panel\Desktop', 'PreferredUILanguagesaaa')
If Not $lang And @OSLang = '040d' Then $lang = 'he-IL'

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

While True
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
        Case $button_add
            add()
        Case $button_remove
            remove()
    EndSwitch
WEnd

Func add()
    If GUICtrlRead($Radio_hebrew) = 1 Then
        $strCmd = 'פתח כאן שורת פקודה'
        $strCmdAdmin = '‏‏‏‏פתח כאן שורת פקודה כמנהל'
    Else
        $strCmd = 'open cmd here'
        $strCmdAdmin = '‏‏open cmd here as administrator'
    EndIf

    For $i = 0 To 2
        RegWrite($reg[$i], 'SubCommands', 'REG_SZ', '')
        RegWrite($reg[$i], 'MUIVerb', 'REG_SZ', $strCmd)
        RegWrite($reg[$i], 'icon', 'REG_SZ', 'cmd.exe')
        RegWrite($reg[$i] & '\shell\cmd', '', 'REG_SZ', $strCmd)
        RegWrite($reg[$i] & '\shell\cmd', 'NoWorkingDirectory', 'REG_SZ', '')
        RegWrite($reg[$i] & '\shell\cmd', 'NeverDefault', 'REG_SZ', '')
        RegWrite($reg[$i] & '\shell\cmd', 'Icon', 'REG_SZ', 'cmd.exe')
        RegWrite($reg[$i] & '\shell\cmd\command', '', 'REG_SZ', 'cmd.exe /s /k pushd "%V"')
        RegWrite($reg[$i] & '\shell\cmdAdministrator', '', 'REG_SZ', $strCmdAdmin)
        RegWrite($reg[$i] & '\shell\cmdAdministrator', 'NoWorkingDirectory', 'REG_SZ', '')
        RegWrite($reg[$i] & '\shell\cmdAdministrator', 'NeverDefault', 'REG_SZ', '')
        RegWrite($reg[$i] & '\shell\cmdAdministrator', 'Icon', 'REG_SZ', 'cmd.exe')
        RegWrite($reg[$i] & '\shell\cmdAdministrator', 'CommandFlags', 'REG_DWORD', '23')
        RegWrite($reg[$i] & '\shell\cmdAdministrator\command', '', 'REG_SZ', StringFormat('wscript "%s" "%V"', $vbs))

        If GUICtrlRead($Radio_hide) = 1 Then RegWrite($reg[$i], 'Extended', 'REG_SZ', '')
        If GUICtrlRead($Radio_show) = 1 Then RegDelete($reg[$i], 'Extended')

    Next

    If FileExists($vbs) Then FileDelete($vbs)
    FileWrite($vbs, 'Dim Arg, var1' & @CRLF & _
        'Set Arg = WScript.Arguments' & @CRLF & _
        'Set Shell = CreateObject("Shell.Application")' & @CRLF & _
        'Shell.ShellExecute "cmd", "/k pushd " & Arg(0), , "runas", 1')
EndFunc   ;==>add

Func remove()
    For $i = 0 To 2
        RegDelete($reg[$i])
    Next
    FileDelete($vbs)
EndFunc   ;==>remove
