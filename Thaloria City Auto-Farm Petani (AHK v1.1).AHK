; ==============================================================================
; Thaloria City Auto-Farm Petani (AHK v1.1) - 12 Petak Presisi
; Controls: F1 = Start/Pause | F2 = Emergency Reload / Reset
; ==============================================================================
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Client
CoordMode, Pixel, Client
SetBatchLines, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0

global isRunning := false
global cycleCount := 0

; Array Koordinat 12 Petak Lengkap
global plotX := [899, 781, 1006, 657, 891, 1118, 784, 1032, 1248, 899, 1137, 1026]
global plotY := [495, 545, 550, 607, 607, 604, 670, 672, 671, 737, 721, 785]

; --- PANEL UTAMA (UI) ---
Gui, +AlwaysOnTop +ToolWindow -Caption +Border
Gui, Color, 141414
Gui, Font, s10 c2ECC71 Bold, Segoe UI
Gui, Add, Text, w210 Center, 🌾 Thaloria AHK (12 Petak)
Gui, Font, s9 cF1C40F Normal
Gui, Add, Text, vStatusTxt w210, Status: Stopped
Gui, Font, s8 cAAAAAA Normal
Gui, Add, Text, w210 Center, [F1] Start / Pause  |  [F2] Reload
Gui, Font, s9 c000000 Normal
Gui, Add, Button, w210 h25 gGuiClose, ❌ Exit Bot
Gui, Show, x30 y30 NoActivate, Thaloria AHK Bot
return

; --- TOMBOL PENGONTROL ---
F1::
    isRunning := !isRunning
    if (isRunning) {
        UpdateUI("Bot Berjalan...", "2ECC71")
        SetTimer, MainLoop, 350
    } else {
        UpdateUI("Paused", "E74C3C")
        SetTimer, MainLoop, Off
    }
return

F2:: Reload

; --- PROSES UTAMA ---
MainLoop:
    if (!isRunning)
        return

    WinGetPos, , , winW, winH, A

    ; 1. DETEKSI TOMBOL MULAI / KERJA LAGI
    PixelSearch, px, py, winW*0.4, winH*0.5, winW*0.6, winH*0.8, 0x5CE76B, 15, Fast RGB
    if (!ErrorLevel) {
        cycleCount++
        UpdateUI("Tekan Lagi", "2ECC71")
        Click, %px%, %py%
        Sleep, 1200
        return
    }

    ; 2. PINDAI PANEN (ORANYE) UTAMA, LALU SIRAM (PUTIH)
    foundAction := false
    Loop, 12
    {
        tX := plotX[A_Index]
        tY := plotY[A_Index]
        
        ; Prioritas 1: Cek warna ORANYE (Panen) di atas petak
        PixelSearch, bx, by, tX-20, tY-90, tX+20, tY-40, 0xF5A623, 30, Fast RGB
        
        ; Prioritas 2: Jika tidak ada oranye, cek warna PUTIH (Siram / Panen Fasa 2)
        if (ErrorLevel) {
            PixelSearch, bx, by, tX-20, tY-90, tX+20, tY-40, 0xFFFFFF, 10, Fast RGB
        }
        
        ; Jika salah satu ikon ditemukan, klik PETAK-nya saja
        if (!ErrorLevel) {
            UpdateUI("Panen/Siram Petak #" . A_Index, "3498DB")
            Click, %tX%, %tY%
            Sleep, 200
            foundAction := true
            break
        }
    }

    if (foundAction)
        return

    ; 3. TANAM BIBIT HANYA DI PETAK YANG BELUM DITANAMI
    isPlanting := false
    Loop, 12
    {
        if (!isRunning)
            break
            
        tX := plotX[A_Index]
        tY := plotY[A_Index]
        
        ; Cek piksel hijau tanaman (0x4E9A2F) di tengah petak
        PixelSearch, gx, gy, tX-20, tY-20, tX+20, tY+20, 0x4E9A2F, 30, Fast RGB
        
        ; Jika TIDAK ADA warna hijau (ErrorLevel = 1), petak dipastikan KOSONG
        if (ErrorLevel) {
            if (!isPlanting) {
                UpdateUI("Menanam Bibit...", "F1C40F")
                isPlanting := true
            }
            Click, %tX%, %tY%
            Sleep, 150
        }
    }

    if (isPlanting) {
        Sleep, 800
        return
    }

    UpdateUI("Menunggu Tumbuh...", "2ECC71")
return

UpdateUI(text, colorHex) {
    GuiControl, Text, StatusTxt, Status: %text%
    GuiFont := "c" . colorHex
    GuiControl, Font, StatusTxt
}

GuiClose:
    ExitApp