#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.2
 Author:         Bohyzeke

 Script Function:
	Odstranenie democasu z programu EKM.
    kopirovanie projektu z kniznice projektou
    Zalohovanie aktualneho projektu
    v1.0.0

#ce ----------------------------------------------------------------------------

Opt("MustDeclareVars", 1)       ;0=no, 1=require pre-declare

; zakladne definicie premennych
; premenne pre ini
Global $Path
; Premenne pouzite v programe
Global $message,$File,$path2

; Premenne pouzite v GUI
; GUI Hlavne
Global $MainWin,$GUIName
; GUI tlacidla
Global $GUI_B_Browse, $GUI_B_Remove, $GUI_B_Restore, $GUI_B_Backup,$GUI_B_Start,$GUI_B_Stop
; GUI Inputs
Global $GUI_Cesta
Global $GUI_T_projekt, $GUI_L_Descript
Global $msg

#Include <WinAPI.au3>
#Include <FileConstants.au3>
#Include <File.au3>
#Include <GUIConstants.au3>
#Include <GUIConstantsEx.au3>
#Include <GuiListView.au3>
#Include <Array.au3>


Dim $INI = @ScriptDir & "\Settings.ini"
Local $Path = IniRead($INI,"Last","Path",@ScriptDir)

; Vytvorenie GUI
$GUIName = "EKM Demo hack"
$MainWin = GUICreate($GUIName,500,500, -1, -1);,$WS_SIZEBOX)
GuiSetIcon($Path & "\ekm.exe", 0)
GUISetState (@SW_SHOW)

; Vytvorenie prvkov GUI
$GUI_Cesta = GUICtrlCreateInput($Path,10,10,180,20)
$GUI_B_Browse = GUICtrlCreateButton("Browse",200,10,70,20,$BS_DEFPUSHBUTTON)

$GUI_B_Backup = GUICtrlCreateButton("Backup",320,10,70,20,$BS_DEFPUSHBUTTON)
$GUI_B_Remove = GUICtrlCreateButton("Hack time",320,35,70,20,$BS_DEFPUSHBUTTON)

$GUI_B_Start = GUICtrlCreateButton("Start",400,10,70,20,$BS_DEFPUSHBUTTON)
$GUI_B_Stop  = GUICtrlCreateButton("Stop",400,35,70,20,$BS_DEFPUSHBUTTON)

$GUI_B_Restore = GUICtrlCreateButton("Restore",80,50,70,20,$BS_DEFPUSHBUTTON)
; $BClear = GUICtrlCreateButton(IniRead($Language,"Butons","Clear","Vymaz"),300,10,80,20,$BS_DEFPUSHBUTTON)
$GUI_T_Projekt = GUICtrlCreateListView("",10,80,210,400)
_GUICtrlListView_AddColumn($GUI_T_Projekt, "Projekt", 200)
;$GUI_L_Descript = GUICtrlCreateList("c.|Projekt",230,80,210,400)
_load()
GuiSetState()

While 1
    $msg = GUIGetMsg()

    If $msg = $GUI_B_Browse Then              ;Vykona sa pri stlaceni tlacidla Browse
        $message = "Otvor."
        $File = FileSelectFolder($message, $Path & "\",1)
        If @error <> 1 Then
            IniWrite($INI,"Last","Path",$File)
            GUICtrlSetData($GUI_Cesta, $File)
            $Path=$File
            _load()
        EndIf
    EndIf
    If $msg = $GUI_B_Remove Then _ResetTime()
    If $msg = $GUI_B_Backup Then _Backup()
    If $msg = $GUI_B_Restore Then _Restore()
    If $msg = $GUI_B_Start Then _EKMStart()
    If $msg = $GUI_B_Stop Then _EKMkill()
    If $msg = $GUI_T_Projekt Then
            MsgBox(0,"Tabulka","Oznacenie")
    EndIf
    If $msg = $GUI_EVENT_CLOSE Then ExitLoop
WEnd
GUIDelete()
Exit

; _Restore()
; Status:
; Popis: Funkcia Obnovenie vybraneho projektu
; Pouzite externe funkcie:
Func _Restore()
    Local $temp,$temp1
    $temp = Number(_GUICtrlListView_GetSelectedIndices($GUI_T_Projekt))
    $temp = _GUICtrlListView_GetItemText($GUI_T_Projekt,$temp)
    _EKMkill()

    Local Const $Templ_Path = $path2 & $temp & "\"
    Local Const $Desti_Path = $path & "\"
    ;MsgBox(0,"title",$Templ_Path & @CRLF & $Desti_Path)
    IF FileExists($Templ_Path) Then
        ;MsgBox(0,"Folder Found","The folder " & $Templ_Path & " Exists")
        DirCopy($Templ_Path , $Desti_Path , $FC_OVERWRITE)
    Else
       MsgBox(0,"Folder Not Found","The folder " & $Templ_Path & " Not exists")
       Exit
    EndIf


EndFunc

; _EKMkill()
; Status:
; Popis: Funkcia na zatvorenie beziacich procesov
; Pouzite externe funkcie:
Func _EKMkill()
    ProcessClose ("ekm.exe")
    ProcessClose("EKMServer.exe")
    ProcessClose("EKMServer.exe")
    ;_ArrayDisplay(ProcessList(),"process")
EndFunc

; _EKMStart()
; Status:
; Popis: Funkcia na spustenie programu
; Pouzite externe funkcie:
Func _EKMStart()
    Run ($Path&"\ekm.exe")

EndFunc

; _Rload()
; Status:
; Popis: Funkcia pre zobrazenie Databaz
; Pouzite externe funkcie:
Func _load()
    Local $Temp,$i,$n
    $n = 0
    $path2 = @ScriptDir &"\Databases\"
    Local $aFolderList = _FileListToArray($Path2, "*",2)

    _GUICtrlListView_DeleteAllItems($GUI_T_Projekt)
    ;_ArrayDisplay($aFolderList, "2D display") ; Note columns truncated
    ;MsgBox(0,'spolu',$aFolderList[0])
    For $i = 1 To $aFolderList[0]
        ;$Temp = $aiResult[$i-1]
        ;MsgBox(0,'data',$aFolderList[$i])
        _GUICtrlListView_AddItem($GUI_T_projekt,$aFolderList[$i])
        $n=$n+1
    Next

EndFunc


; _Backup()
; Status:
; Popis: Funkcia Odzalohovanie aktualneho projektu
; Pouzite externe funkcie:
Func _Backup()
    Local $FolderN, $FilePath
    ; Local Const $Path = @ScriptDir
    Local Const $Source_Path = $Path & "\DB"

    $FolderN = @YEAR&@MON&@MDAY&@HOUR&@MIN&@SEC&"_DB"
    Local $Destination_Path = $Path & "\" & $FolderN

    IF FileExists($Source_Path) Then
        DirCopy($Source_Path , $Destination_Path & "\DB", $FC_OVERWRITE)
    Else
       MsgBox(0,"Folder Not Found","The folder " & $Source_Path & " Not exists")
       Exit
    EndIf

    $FilePath = $Path&"\readme.txt"
    IF FileExists($FilePath) Then
        FileCopy($FilePath, $Destination_Path& "\", $FC_OVERWRITE)
    Else
       MsgBox(0,"File Not Found","The file " & $FilePath & " Not exists")
       Exit
    EndIf

EndFunc



; _ResetTime
; Status:
; Popis: Funkcia pre resetnutie Demo Casu
; Pouzite externe funkcie: HexWrite($FilePath, $Offset, $BinaryValue),HexRead($FilePath, $Offset, $Length)
Func _ResetTime()
    _EKMkill()
    Local $Keys_Path = $Path & "\DB"& "\Keys.dat"
    Local $TestFile_ID, $bData, $Offset

    ;## nastavenie ofsetu a dlzky kodu pre reset
    Local Const $Offset_Reset[2]  = [0x00, 48]

    ;## binarny string pre reset suboru 'Keys.dat'.
    Local Const $Reset_Data = "0x3600000000020000050000000002000000010000000701200002007048CBB3E8FA23C100000000000000000000000000"

    ;## Nacitani povodnej hodnoty v subore
    $bData = _HexRead($Keys_Path, $Offset_Reset[0], $Offset_Reset[1])
    if @error Then
        MsgBox(4096, Default, "Chyba:"& @error)
        Exit
    EndIf
    ;## Zobrazenie povodnej hodnoty v subore.
    ;MsgBox(4096, Default, "stare data:" & @CRLF & $bData& @CRLF &$Reset_Data)

    ;## Nahradenie retazca v subore
    _HexWrite($Keys_Path, $Offset_Reset[0], Binary($Reset_Data))
    if @error Then
        MsgBox(4096, Default, "Chyba:"& @error)
        Exit
    EndIf

    ;## Nacitanie zmeneneho retazca v subore
    $bData = _HexRead($Keys_Path, $Offset_Reset[0], $Offset_Reset[1])

    ;## Zobrazenie novej hodnoty v subore.
    ;MsgBox(4096, Default, "Nove data:" & @CRLF & $bData)
    _EKMStart()
EndFunc

#Region ;**** HexEdit Functions

    Func _HexWrite($FilePath, $Offset, $BinaryValue)
        Local $Buffer, $ptr, $bLen, $fLen, $hFile, $Result, $Written,$err

        ;## Parameter Checks
            If Not FileExists($FilePath)    Then    Return SetError(1, @error, 0)
            $fLen = FileGetSize($FilePath)
            If $Offset > $fLen              Then    Return SetError(2, @error, 0)
            If Not IsBinary($BinaryValue)   Then    Return SetError(3, @error, 0)
            $bLen = BinaryLen($BinaryValue)
            If $bLen > $Offset + $fLen      Then    Return SetError(4, @error, 0)

        ;## Place the supplied binary value into a dll structure.
            $Buffer = DllStructCreate("byte[" & $bLen & "]")

            DllStructSetData($Buffer, 1, $BinaryValue)
            If @error Then Return SetError(5, @error, 0)

            $ptr = DllStructGetPtr($Buffer)

        ;## Open File
            $hFile = _WinAPI_CreateFile($FilePath, 2, 4, 0)
            If $hFile = 0 Then Return SetError(6, @error, 0)

        ;## Move file pointer to offset location
            $Result = _WinAPI_SetFilePointer($hFile, $Offset)
            $err = @error
            If $Result = 0xFFFFFFFF Then
                _WinAPI_CloseHandle($hFile)
                Return SetError(7, $err, 0)
            EndIf

        ;## Write new Value
            $Result = _WinAPI_WriteFile($hFile, $ptr, $bLen, $Written)
            $err = @error
            If Not $Result Then
                _WinAPI_CloseHandle($hFile)
                Return SetError(8, $err, 0)
            EndIf

        ;## Close File
            _WinAPI_CloseHandle($hFile)
            If Not $Result Then Return SetError(9, @error, 0)
    EndFunc

    Func _HexRead($FilePath, $Offset, $Length)
        Local $Buffer, $ptr, $fLen, $hFile, $Result, $Read, $err, $Pos

        ;## Parameter Checks
            If Not FileExists($FilePath)    Then    Return SetError(1, @error, 0)
            $fLen = FileGetSize($FilePath)
            If $Offset > $fLen              Then    Return SetError(2, @error, 0)
            If $fLen < $Offset + $Length    Then    Return SetError(3, @error, 0)

        ;## Define the dll structure to store the data.
            $Buffer = DllStructCreate("byte[" & $Length & "]")
            $ptr = DllStructGetPtr($Buffer)

        ;## Open File
            $hFile = _WinAPI_CreateFile($FilePath, 2, 2, 0)
            If $hFile = 0 Then Return SetError(5, @error, 0)

        ;## Move file pointer to offset location
            $Pos = $Offset
            $Result = _WinAPI_SetFilePointer($hFile, $Pos)
            $err = @error
            If $Result = 0xFFFFFFFF Then
                _WinAPI_CloseHandle($hFile)
                Return SetError(6, $err, 0)
            EndIf

        ;## Read from file
            $Read = 0
            $Result = _WinAPI_ReadFile($hFile, $ptr, $Length, $Read)
            $err = @error
            If Not $Result Then
                _WinAPI_CloseHandle($hFile)
                Return SetError(7, $err, 0)
            EndIf

        ;## Close File
            _WinAPI_CloseHandle($hFile)
            If Not $Result Then Return SetError(8, @error, 0)

        ;## Return Data
            $Result = DllStructGetData($Buffer, 1)

            Return $Result
    EndFunc

    Func _HexSearch($FilePath, $BinaryValue, $StartOffset = Default)
        Local $Buffer, $ptr, $hFile, $Result, $Read, $SearchValue, $Pos, $BufferSize = 2048

        ;## Parameter Defaults
            If $StartOffset = Default       Then    $StartOffset = 0

        ;## Parameter Checks
            If Not FileExists($FilePath)    Then    Return SetError(1, @error, 0)
            $fLen = FileGetSize($FilePath)
            If $StartOffset > $fLen         Then    Return SetError(2, @error, 0)
            If Not IsBinary($BinaryValue)   Then    Return SetError(3, @error, 0)
            If Not IsNumber($StartOffset)   Then    Return SetError(4, @error, 0)

        ;## Prep the supplied binary value for search
            $SearchValue = BinaryToString($BinaryValue)

        ;## Define the dll structure to store the data.
            $Buffer = DllStructCreate("byte[" & $BufferSize & "]")
            $ptr = DllStructGetPtr($Buffer)

        ;## Open File
                $hFile = _WinAPI_CreateFile($FilePath, 2, 2, 1)
                If $hFile = 0 Then Return SetError(5, @error, 0)

        ;## Move file pointer to offset location
            $Result = _WinAPI_SetFilePointer($hFile, $StartOffset)
            $err = @error
            If $Result = 0xFFFFFFFF Then
                _WinAPI_CloseHandle($hFile)
                Return SetError(5, $err, 0)
            EndIf

        ;## Track the file pointer's position
            $Pos = $StartOffset

        ;## Start Search Loop
            While True

                ;## Read from file
                    $Read = 0
                    $Result = _WinAPI_ReadFile($hFile, $ptr, $BufferSize, $Read)
                    $err = @error
                    If Not $Result Then
                        _WinAPI_CloseHandle($hFile)
                        Return SetError(6, $err, 0)
                    EndIf

                ;## Prep read data for search
                    $Result = DllStructGetData($Buffer, 1)
                    $Result = BinaryToString($Result)

                ;## Search the read data for first match
                    $Result = StringInStr($Result, $SearchValue)
                    If $Result > 0 Then ExitLoop

                ;## Test for EOF and return -1 to signify value was not found
                    If $Read < $BufferSize Then
                        _WinAPI_CloseHandle($hFile)
                        Return -1
                    EndIf

                ;## Value not found, Continue Tracking file pointer's position
                    $Pos += $Read

            WEnd

        ;## Close File
            _WinAPI_CloseHandle($hFile)
            If Not $Result Then Return SetError(7, @error, 0)

        ;## Calculate the offset and return
            $Result = $Pos + $Result - 1
            Return $Result
    EndFunc

#EndRegion