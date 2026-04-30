#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SendMode Input
SetBatchLines -1

; --- Global Variables ---
global EN_TO_HE := {"q":"/", "w":"'", "e":"ק", "r":"ר", "t":"א", "y":"ט", "u":"ו", "i":"ן", "o":"ם", "p":"פ", "[":"]", "]":"[", "a":"ש", "s":"ד", "d":"ג", "f":"כ", "g":"ע", "h":"י", "j":"ח", "k":"ל", "l":"ך", ";":"ף", "'":",", "z":"ז", "x":"ס", "c":"ב", "v":"ה", "b":"נ", "n":"מ", "m":"צ", ",":"ת", ".":"ץ", "/":"."}

; --- Hotkey Definition ---
!+j::
{
    ; 1. Remove CapsLock if active
    if (GetKeyState("CapsLock", "T"))
    {
        SetCapsLockState, Off
    }

    ; 2. Get selected text
    ClipboardOld := ClipboardAll()
    Clipboard := ""
    
    ; Send Ctrl+C to copy selected text
    Send, ^c
    ClipWait, 1
    
    if (ErrorLevel)
    {
        Clipboard := ClipboardOld
        return
    }
    
    SelectedText := Clipboard
    
    if (SelectedText = "")
    {
        Clipboard := ClipboardOld
        return
    }
    
    ; 3. Convert text
    ConvertedText := ConvertText(SelectedText)
    
    ; 4. Replace with converted text
    Clipboard := ConvertedText
    Send, ^v
    Sleep, 50
    
    ; 5. Restore clipboard
    Clipboard := ClipboardOld
    
    ; 6. Switch keyboard language
    SwitchKeyboardLanguage()
}

; --- Function to Switch Keyboard Language ---
SwitchKeyboardLanguage()
{
    ; Get active window
    WinGet, active_id, ID, A
    
    ; Get thread ID
    ThreadID := DllCall("GetWindowThreadProcessId", "UInt", active_id, "UInt", 0)
    
    ; Get current keyboard layout
    InputLocaleID := DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")
    
    ; Extract language ID (lower 16 bits)
    LangID := InputLocaleID & 0xFFFF
    
    ; HE = 0x040D (1037), EN = 0x0409 (1033)
    if (LangID = 0x0409 or LangID = 1033)
    {
        ; Switch to Hebrew
        PostMessage, 0x50, 0, 0x040D040D,, A
    }
    else if (LangID = 0x040D or LangID = 1037)
    {
        ; Switch to English
        PostMessage, 0x50, 0, 0x04090409,, A
    }
}

; --- Text Conversion Function ---
ConvertText(text)
{
    result := ""
    
    Loop, Parse, text
    {
        char := A_LoopField
        
        ; Check if character exists in EN_TO_HE map
        if (EN_TO_HE.HasKey(char))
        {
            result .= EN_TO_HE[char]
        }
        else
        {
            ; Try lowercase
            StringLower, lowerChar, char
            if (EN_TO_HE.HasKey(lowerChar))
            {
                result .= EN_TO_HE[lowerChar]
            }
            else
            {
                ; Keep original character
                result .= char
            }
        }
    }
    
    return result
}

; --- Tray Menu ---
Menu, Tray, NoStandard
Menu, Tray, Add, &Pause, PauseScript
Menu, Tray, Add, &Exit, ExitScript
Menu, Tray, Default, &Pause

; --- Pause Script Function ---
PauseScript:
{
    Pause
    return
}

; --- Exit Script Function ---
ExitScript:
{
    ExitApp
}
