.INCLUDE "Variables.inc"

.SEGMENT "BANK_00_00"


.EXPORT DriveAudio

.IFNDEF PAL
    .RES $60
.ENDIF

SongTable:
    .BYTE $7D, $B5, $6E, $67, $7D, $AD, $64, $64
    .BYTE $75, $7D, $85, $95, $7D, $8D, $95, $9D
    .BYTE $A5, $BD, $C5, $CD, $D5, $DD, $D5, $E5
    .BYTE $ED, $24, $2C, $34, $3C, $44, $34, $4C
    .BYTE $54, $5C, $44, $F5

; Description:
; Each song phrase is described by a header in this format:
;
; 0: Note length table base
; 1: Song script address low
; 2: Song script address high
; 3: Triangle note offset in script
; 4: Square 0 note offset in script
; 5: Noise note offset in script
; 6: Envelope selector
; 7: TODO:
;
; Note that the last byte of the "Item taken" header overlaps
; "End level", and "End level" overlaps "Overworld".
;
.MACRO SongHeader arg1, arg2, arg3, arg4, arg5, arg6, arg7
    .BYTE arg1
    .WORD arg2
    .IFNBLANK arg3
        .BYTE arg3, arg4, arg5, arg6
        .IFNBLANK arg7
            .BYTE arg7
        .ENDIF
    .ENDIF
.ENDMACRO

SongHeaderDemo0:
    SongHeader $20, SongScriptDemo0,           $3B, $1D, $4F, $80, $01
    SongHeader $20, SongScriptDemo0+$51,       $27, $57, $23, $01, $80
    SongHeader $20, SongScriptDemo0+$116,      $38, $17, $B8, $80, $80
    SongHeader $20, SongScriptDemo0+$166,      $6C, $26, $68, $80, $80
    SongHeader $20, SongScriptDemo0+$202,      $3E, $25, $21, $80, $80
    SongHeader $20, SongScriptDemo0+$260,      $19, $0D, $31, $80, $80
    SongHeader $20, SongScriptDemo0+$295,      $3F, $27, $7C, $80, $80
    SongHeader $20, SongScriptDemo0+$304,      $1D, $11, $0D, $80, $80

; Unknown block
    SongHeader $10, SongScriptOverworld0+NTSCPAL $31, $38

SongHeaderItemTaken0:
    SongHeader NTSCPAL $10, $18, SongScriptItemTaken0,      $0D, $07, $00, $80

SongHeaderEndLevel0:
    SongHeader $10, SongScriptEndLevel0,       NTSCPAL $46, $4A, NTSCPAL $22, $24, $00, $80

SongHeaderOverworld0:
.IFNDEF PAL
    SongHeader $10, SongScriptOverworld0,      $32, $5D, $8E, $01, $80
    SongHeader $10, SongScriptOverworld0+$9F,  $35, $16, $CE, $01, $80
    SongHeader $10, SongScriptOverworld0+$E5,  $60, $26, $88, $01, $80
    SongHeader $10, SongScriptOverworld0+$1C2, $59, $2D, $A4, $01, $80
    SongHeader $10, SongScriptOverworld0+$174, $3B, $1A, $F2, $01, $80
.ELSE
    SongHeader $10, SongScriptOverworld0,      $39, $6A, $A2, $01, $80
    SongHeader $10, SongScriptOverworld0+$B3,  $36, $17, $DE, $01, $80
    SongHeader $10, SongScriptOverworld0+$FC,  $67, $28, $95, $01, $80
    SongHeader $10, SongScriptOverworld0+$1EF, $59, $2D, $AE, $01, $80
    SongHeader $10, SongScriptOverworld0+$198, $3B, $1A, $50, $01, $80
.ENDIF

SongHeaderUnderworld0:
    SongHeader $00, SongScriptUnderworld0,     $45, $22, $00, $01, $01
    SongHeader $00, SongScriptUnderworld0+$5D, $39, $1C, $00, $01, $01

SongHeaderLastLevel0:
    SongHeader NTSCPAL $10, $18, SongScriptLastLevel0,      $A5, $53, $CD, $80, $80

SongHeaderGanon0:
    SongHeader NTSCPAL $10, $18, SongScriptGanon0,          $22, $10, $00, $80, $01

SongHeaderEnding0:
    SongHeader $08, SongScriptEnding0,         $22, $50, $59, $01, $80
    SongHeader $08, SongScriptEnding0,         $2F, $50, $59, $01, $80
    SongHeader $08, SongScriptEnding0+$5B,     $7A, $1B, $C2, $80, $80
    SongHeader $08, SongScriptEnding0+$8F,     $46, $24, $8E, $01, $80
    SongHeader $08, SongScriptEnding0+$A6,     $44, $23, $77, $01, $80
    SongHeader $08, SongScriptEnding0+$F6,     $1B, $0E, $27, $01, $80
    SongHeader $08, SongScriptEnding0+$123,    $40, $1A, $6B, $80, $80

SongHeaderZelda:
    SongHeader $10, SongScriptZelda0,          NTSCPAL $3F, $43, NTSCPAL $20, $22, $00, $80, $80

SongScriptItemTaken0:
    .INCBIN "dat/SongScriptItemTaken0.dat"

SongScriptOverworld0:
    .INCBIN "dat/SongScriptOverworld0.dat"

SongScriptUnderworld0:
    .INCBIN "dat/SongScriptUnderworld0.dat"

SongScriptEndLevel0:
    .INCBIN "dat/SongScriptEndLevel0.dat"

SongScriptLastLevel0:
    .INCBIN "dat/SongScriptLastLevel0.dat"

SongScriptGanon0:
    .INCBIN "dat/SongScriptGanon0.dat"

SongScriptEnding0:
    .INCBIN "dat/SongScriptEnding0.dat"

SongScriptDemo0:
    .INCBIN "dat/SongScriptDemo0.dat"

SongScriptZelda0:
    .INCBIN "dat/SongScriptZelda0.dat"

DriveAudio:
    ; If the game is paused, then silence all channels
    ; by first disabling them, then enabling them.
    ;
    ; Then go drive tune channel 0 only.
    LDA Paused
    BEQ @Play
    LDA #$00
    STA ApuStatus_4015
    LDA #$0F
    STA ApuStatus_4015
    BNE @Paused

@Play:
    ; Else the game is not paused.
    ;
    ; Synchronize the APU frame counter once a video frame.
    LDA #$FF
    STA Ctrl2_FrameCtr_4017

    ; Drive each game sound channel.
    JSR DriveTune1
    JSR DriveEffect
    JSR DriveSample
    JSR DriveSong

@Paused:
    JSR DriveTune0

    ; Reset all requests for sound.
    LDA #$00
    STA Tune0Request
    STA EffectRequest
    STA Tune1Request
    STA SampleRequest
    STA SongRequest
    RTS

TuneScripts0:
    .BYTE $1C, $4C, $27, $5C, $46, $67, $07, $95
    .BYTE $50, $08, $08, $08, $08, $08, $90, $08
    .BYTE $08, $08, $08, $08, $08, $08, $08, $08
    .BYTE $08, $08, $08, $00, $82, $4A, $48, $4A
    .BYTE $08, $08, $08, $08, $08, $08, $00, $9F
    .BYTE $1E, $22, $24, $26, $9F, $28, $2A, $2C
    .BYTE $2E, $9A, $28, $2A, $2C, $2E, $9C, $28
    .BYTE $2A, $2C, $2E, $96, $28, $2A, $2C, $2E
    .BYTE $98, $28, $2A, $2C, $2E, $00, $99, $42
    .BYTE $4A, $50, $54, $00, $99, $70, $0A, $70
    .BYTE $0E, $70, $10, $9F, $70, $2A, $12, $1E
    .BYTE $2A, $70, $1E, $00, $9A, $42, $08, $08
    .BYTE $56, $08, $08, $00, $08, $08, $00, $9F
    .BYTE $40, $30, $40, $3A, $28, $00

L18C9_SilenceSong:
    JMP SilenceSong

DriveTune0:
    LDA Tune0Request

    ; Tune $80 is only a signal to silence the song.
    BMI L18C9_SilenceSong
    BEQ @CheckCurrentTune

    ; If the requested tune is not "heart warning", then go play it.
    CMP #$40
    BNE @ChangeTune

    ; Else only play "heart warning" if nothing else is playing.
    LDX Tune0
    BEQ @ChangeTune

@CheckCurrentTune:
    LDA Tune0
    BNE @KeepPlaying
    RTS

@ChangeTune:
    STA Tune0
    LDY #$00
:
    ; Get the index for the song bit: 1 to 8.
    INY
    LSR
    BCC :-
    LDA TuneScripts0-1, Y
    STA TunePtr0

@KeepPlaying:
    LDY TunePtr0
    INC TunePtr0
    LDA TuneScripts0, Y
    BMI @PrepNote
    BNE @PlayNote

    ; We've reached the end of the tune.
    LDX #$90
    STX Sq0Duty_4000
    LDX #$18
    STX Sq0Length_4003
    LDX #$00
    STX Sq0Timer_4002
    STX Tune0
    RTS

@PrepNote:
    STA Sq0Duty_4000
    LDY TunePtr0
    INC TunePtr0
    LDA TuneScripts0, Y

@PlayNote:
    JSR EmitSquareNote0
    LDA #$7F
    STA Sq0Sweep_4001
    RTS

SilenceSample:
    LDA #$0F
    STA ApuStatus_4015
    LDA #$00
    STA Sample
    STA Tune1
    STA $061A
    STA BackgroundSample
    RTS

PlayArrowSfx:
    STY Effect
    LDA #$05
    STA EffectCounter

    ; If "heart taken" is requested in tune channel 0, then cancel it.
    LDA Tune0Request
    AND #$EF
    BNE ContinueArrowSfx
    STA Tune0Request

ContinueArrowSfx:
    LDY EffectCounter
    LDA ArrowSfxNotes-1, Y
    BNE PlaySfxNote

PlayStairsSfx:
    STY Effect
    LDA #$38
    STA EffectCounter
:
    LDA #$0D
    STA $68                     ; The sound of one step lasts $C frames.

ContinueStairsSfx:
    DEC $68
    LDY $68
    BEQ :-
    CPY #$07
    BCC :+
    LDA #$10
    BNE SetSfxVolumeLength
:
    LDA StairsSfxNotes-1, Y

PlaySfxNote:
    TAX
    AND #$0F
    STA NoisePeriod_400E
    TXA
    LSR
    LSR
    LSR
    LSR
    ORA #$10

SetSfxVolumeLength:
    STA NoiseVolume_400C
    LDA #$08
    STA NoiseLength_400F
    DEC EffectCounter

SilenceSfxIfEnded:
    BNE :+
    LDA #$F0
    STA NoiseVolume_400C
    LDA #$00
    STA Effect
:
    RTS

PlaySwordSfx:
    STY Effect
    LDA #$0A
    STA EffectCounter

ContinueSwordSfx:
    LDY EffectCounter
    LDA SwordSfxNotes-1, Y
    BNE PlaySfxNote

DriveEffect:
    LDY EffectRequest

    ; $80 is a signal to silence samples and tune 1.
    BMI SilenceSample
    LDA Effect
    LSR EffectRequest
    BCS PlaySwordSfx
    LSR
    BCS ContinueSwordSfx
    LSR EffectRequest
    BCS PlayArrowSfx
    LSR
    BCS ContinueArrowSfx
    LSR EffectRequest
    BCS @PlayFlameSfx
    LSR
    BCS @ContinueFlameSfx
    LSR EffectRequest
    BCS PlayStairsSfx
    LSR
    BCS ContinueStairsSfx
    LSR EffectRequest
    BCS @PlayBombSfx
    LSR
    BCS @ContinueBombSfx
    LSR
    BCS @ContinueSeaSfx
    LSR EffectRequest
    BCS @PlaySeaSfx
    RTS

@PlayBombSfx:
    STY Effect
    LDA #$18
    STA EffectCounter

@ContinueBombSfx:
    LDY EffectCounter
    LDA BombSfxNotes-1, Y
    BNE PlaySfxNote

@PlayFlameSfx:
    STY Effect
    LDA #$20
    STA EffectCounter

@ContinueFlameSfx:
    LDA EffectCounter
    LSR
    TAY
    LDX #$0E
    STX NoisePeriod_400E
    LDA FlameSfxNotes-1, Y
    JMP SetSfxVolumeLength

@PlaySeaSfx:
    STY Effect
    LDA #$D0
    STA SeaSfxCounter
    LDA #$10
    STA $68                     ; The volume begins and ends at $10.

@ContinueSeaSfx:
    LDA SeaSfxCounter
    CMP #$BF
    BCC :+

    ; SFX counter >= $BF. Increase volume fast.
    INC $68
    BNE @SetSeaSfxParams
:
    ; SFX counter < $BF. Decrease volume slowly down to $10 --
    ; when (counter MOD 8) = 7.
    LDA SeaSfxCounter
    LSR
    BCC @SetSeaSfxParams
    LSR
    BCC @SetSeaSfxParams
    LSR
    BCC @SetSeaSfxParams
    LDA $68
    CMP #$10
    BEQ @SetSeaSfxParams
    DEC $68

@SetSeaSfxParams:
    LDA $68
    STA NoiseVolume_400C
    LDX #$03
    STX NoisePeriod_400E
    LDA #$08
    STA NoiseLength_400F
    DEC SeaSfxCounter
    JMP SilenceSfxIfEnded

BombSfxNotes:
    .BYTE $1F, $2F, $2E, $3F, $3F, $4C, $4E, $5F
    .BYTE $6F, $6F, $7E, $8F, $9E, $AF, $BE, $CF
    .BYTE $DE, $EF, $FE, $FD, $FE, $FF, $FF, $FE

TuneScripts1:
    .BYTE $0C, $08, $11, $1C, $28, $33, $40, $62
.IFNDEF PAL
    .BYTE $8A, $4E, $58, $60, $8A, $5E, $94, $60
    .BYTE $00, $8A, $42, $06, $3C, $30, $2E, $3E
    .BYTE $44, $CC, $02, $00, $83, $40, $42, $48
    .BYTE $4A, $02, $50, $4C, $54, $94, $56, $00
    .BYTE $94, $3A, $3E, $A8, $50, $8A, $4E, $02
    .BYTE $CC, $4A, $00, $81, $28, $3E, $24, $82
    .BYTE $3A, $81, $16, $30, $1A, $82, $34, $00
    .BYTE $94, $56, $42, $02, $4C, $52, $42, $5C
.ELSE
    .BYTE $88, $4E, $58, $60, $88, $5E, $94, $60
    .BYTE $00, $88, $42, $06, $3C, $30, $2E, $3E
    .BYTE $44, $CA, $02, $00, $82, $40, $42, $48
    .BYTE $4A, $02, $50, $4C, $54, $94, $56, $00
    .BYTE $93, $3A, $3E, $A6, $50, $89, $4E, $02
    .BYTE $CA, $4A, $00, $81, $28, $3E, $24, $82
    .BYTE $3A, $81, $16, $30, $1A, $82, $34, $00
    .BYTE $90, $56, $42, $02, $4C, $52, $42, $5C
.ENDIF
    .BYTE $4A, $5A, $02, $4C, $5A, $56, $02, $50
    .BYTE $4C, $5A, $02, $54, $5A, $58, $02, $50
    .BYTE $54, $4C, $42, $02, $4C, $50, $48, $4A
    .BYTE $50, $00
.IFNDEF PAL
.IFNDEF REV1
    .BYTE $8A, $08, $08, $08, $85
.ELSE
    .BYTE $9E, $08, $85
.ENDIF
.ELSE
    .BYTE $90, $08, $08, $84
.ENDIF
    .BYTE $3C
    .BYTE $3A, $38, $36, $3A, $38, $36, $34, $38
    .BYTE $36, $34, $32, $36, $34, $32, $30, $34
    .BYTE $32, $30, $2E, $2A, $28, $A8, $26, $00

DriveTune1:
    LDA Tune1Request
    BMI @SilenceThenPlay
    BNE @ChangeTune
    LDA Tune1
    BNE @KeepPlaying
    RTS

@SilenceThenPlay:
    JSR SilenceSong
    LDA #$80

@ChangeTune:
    STA Tune1
    LDY #$00
:
    ; Get the index for the song bit: 1 to 8.
    INY
    LSR
    BCC :-
    LDA TuneScripts1-1, Y
    STA TunePtr1
    LDA #$01
    STA NoteCounterTune1

@KeepPlaying:
    DEC NoteCounterTune1
    BNE @CheckVibrate
    LDY TunePtr1
    INC TunePtr1
    LDA TuneScripts1, Y
    BMI @PrepNote
    BNE @PlayNote

    ; We've reached the end of the tune.
    ;
    ; If tune is "Game Over", then go play it again.
    LDA Tune1
    CMP #$40
    BEQ @ChangeTune
    LDX #$90
    STX Sq1Duty_4004
    LDX #$18
    STX Sq1Length_4007
    LDX #$00
    STX Tune1
    STX Sq1Timer_4006
    RTS

@PrepNote:
    AND #$7F
    STA NoteLengthTune1
    LDY TunePtr1
    INC TunePtr1
    LDA TuneScripts1, Y

@PlayNote:
    JSR EmitSquareNote1
    LDA #$7F
    STA Sq1Sweep_4005
    LDA #$86
    STA Sq1Duty_4004
    LDA NoteLengthTune1
    STA NoteCounterTune1
    LDA #$1F
    STA CustomEnvelopeOffsetTune1

@CheckVibrate:
    ; If the tune is not one of "flute" or "Link dying", then return.
    LDA Tune1
    AND #$90
    BEQ @Exit
    LDY CustomEnvelopeOffsetTune1
    BEQ :+
    DEC CustomEnvelopeOffsetTune1
:
    LDA CustomEnvelopeTune1, Y
    STA Sq1Duty_4004
    LDA NoteCounterTune1
    LDX CurNoteLowPeriodSq1
    JSR VibratePitch
    STX Sq1Timer_4006

@Exit:
    RTS

CustomEnvelopeTune1:
    .BYTE $95, $96, $97, $98, $99, $9A, $9B, $9C
    .BYTE $9D, $9E, $9F, $9F, $9F, $9F, $9F, $9F
    .BYTE $9F, $9F, $9F, $9F, $9F, $9F, $9F, $9E
    .BYTE $9D, $9C, $9B, $9A, $99, $98, $97, $96

DriveSample:
    LDA SampleRequest
    BMI @ChangeSampleMid
    BNE @ChangeSampleLow
    LDA Sample
    BEQ @CheckBgSample
    DEC SampleCounter
    BNE @Exit
    LDA Sample
.IF .NOT (.DEF(REV1) .OR .DEF(PAL))
    BMI @ChangeSampleMid
    AND #$70
    BNE @ChangeSampleLow
.ELSE
    AND #$70
    BNE :+
.ENDIF
    LDA #$00
    STA Sample
    LDA #$0F
    STA ApuStatus_4015

@CheckBgSample:
    LDA BackgroundSample
    BNE :+

@Exit:
    RTS

@ChangeSampleLow:
    LDX #$00
    BEQ :+

@ChangeSampleMid:
.IF .NOT (.DEF(REV1) .OR .DEF(PAL))
    LDX #$7F
    AND #$F0
.ELSE
    LDX #$40
    AND #$70
.ENDIF
:
    STX DmcCounter_4011
    STA Sample
    TAX
    AND #$F0
    BEQ :+
    STA BackgroundSample
:
    TXA
    LDY #$00
:
    INY
    LSR
    BCC :-
    LDA SampleRates-1, Y
    STA DmcFreq_4010
    LDA SampleAddrs-1, Y
    STA DmcAddress_4012
    LDA SampleLengths-1, Y
    STA DmcLength_4013
    LDA #$A0
    STA SampleCounter
    LDA #$0F
    STA ApuStatus_4015
    LDA #$1F
    STA ApuStatus_4015
    RTS

SampleAddrs:
    .BYTE $00, $4C, $80, $1D, $20, $28, $4C

SampleLengths:
    .BYTE $75, $C0, $40, $0A, $B0, $90, $D0

SampleRates:
    .BYTE $0F, $0F, $0D, $0F, $0E, $0F, $0E

; Params:
; X: duty byte
; Y: sweep byte
;
SetSq0DutyAndSweep:
    STY Sq0Sweep_4001
    STX Sq0Duty_4000
    RTS

EmitSquareNoteWithDutyAndSweep0:
    ; Begin unverified code 1C0A
    JSR SetSq0DutyAndSweep
    ; End unverified code

; Params:
; A: offset of a note in period table
;
EmitSquareNote0:
    TAY
    LDA NotePeriodTable+1, Y
    BEQ Exit
    STA CurNoteLowPeriodSq0
    STA Sq0Timer_4002
    LDA NotePeriodTable, Y
    ORA #$08
    STA Sq0Length_4003

Exit:
    RTS

; Params:
; X: duty byte
; Y: sweep byte
;
SetSq1DutyAndSweep:
    STX Sq1Duty_4004
    STY Sq1Sweep_4005
    RTS

EmitSquareNoteWithDutyAndSweep1:
    ; Begin unverified code 1C28
    JSR SetSq1DutyAndSweep
    ; End unverified code

; Params:
; A: note ID (offset of note in period table)
;
; Returns:
; Y: note ID
; A: 0 if the note is a a rest
;
EmitSquareNote1:
    TAY
    LDA NotePeriodTable+1, Y
    BEQ Exit
    STA CurNoteLowPeriodSq1
    STA Sq1Timer_4006
    LDA NotePeriodTable, Y
    ORA #$08
    STA Sq1Length_4007
    RTS

; Params:
; A: offset of a note in period table
;
EmitTriangleNote:
    TAY
    LDA NotePeriodTable+1, Y
    BEQ Exit
    STA CurNoteLowPeriodTrg
    STA TrgTimer_400A
    LDA NotePeriodTable, Y
    ORA #$08
    STA TrgLength_400B
    RTS

; Params:
; A: note counter
; X: period value
;
; Returns:
; X: (period - 1) to (period + 1)
;
; If note counter < $10, then return.
;
VibratePitch:
    CMP #$10
    BCC @Exit

    ; Is bit 2 set?
    LSR
    LSR
    LSR
    BCS @GoDown

    ; If not set, then add 1 to X.
    TXA
    ADC #$01
    BNE :+

@GoDown:
    ; If set, then subtract 1 from X.
    TXA
    CLC
    ADC #$FF
:
    TAX

@Exit:
    RTS

KeepPlaying:
    JMP KeepPlayingSong

DriveSong:
    LDA SongRequest
    BNE @ChangeSong
    LDA Song
    BNE KeepPlaying
    RTS

@ChangeSong:
    STA Song
    BMI @PlayFirstDemoPhrase
    CMP #$06
    BNE :+
    LDY #$24
    BNE PrepPhrase
:
    CMP #$01
    BEQ @PlayFirstOverworldPhrase
    CMP #$40
    BEQ @PlayFirstUnderworldPhrase
    CMP #$10
    BNE PlayNextPhrase
    LDY #$11
    BNE SetPrevPhraseIndex

@PlayFirstDemoPhrase:
    LDY #$19
    BNE SetPrevPhraseIndex

@PlayFirstUnderworldPhrase:
    LDY #$0F
    BNE SetPrevPhraseIndex

@PlayFirstOverworldPhrase:
    LDY #$08

SetPrevPhraseIndex:
    STY SongPhraseIndex

PlayNextPhrase:
    TAX
    BMI @PlayNextDemoPhrase
    CMP #$01
    BEQ @PlayNextOverworldPhrase
    CMP #$40
    BEQ @PlayNextUnderworldPhrase
    CMP #$10
    BNE @PlaySinglePhraseSong

    ; Play the next phrase of the ending song.
    INC SongPhraseIndex
    LDY SongPhraseIndex
    CPY #$1A
    BNE PrepPhrase
    LDY #$14
    BNE SetPrevPhraseIndex

@PlayNextUnderworldPhrase:
    INC SongPhraseIndex
    LDY SongPhraseIndex
    CPY #$12
    BNE PrepPhrase
    LDY #$0F
    BNE SetPrevPhraseIndex

@PlayNextOverworldPhrase:
    INC SongPhraseIndex
    LDY SongPhraseIndex
    CPY #$10
    BNE PrepPhrase
    LDY #$09
    BNE SetPrevPhraseIndex

@PlayNextDemoPhrase:
    INC SongPhraseIndex
    LDY SongPhraseIndex
    CPY #$24
    BNE PrepPhrase
    LDY NTSCPAL #$19, #$1B
    BNE SetPrevPhraseIndex

@PlaySinglePhraseSong:
    ; Get the index for the song bit: 2 to 6.
    TXA
    LDY #$00
:
    INY
    LSR
    BCC :-

PrepPhrase:
    LDA SongTable-1, Y
    TAY
    LDA SongTable, Y
    STA NoteLengthTableBase
    LDA SongTable+1, Y
    STA SongScriptPtrLo
    LDA SongTable+2, Y
    STA SongScriptPtrHi
    LDA SongTable+3, Y
    STA NoteOffsetSongTrg
    LDA SongTable+4, Y
    STA NoteOffsetSongSq0
    LDA SongTable+5, Y
    STA NoteOffsetSongNoise
    STA FirstNoteIndexSongNoise
    LDA SongTable+6, Y
    STA SongEnvelopeSelector
    LDA SongTable+7, Y
    STA $05F1                   ; TODO: [05F1]
    LDA #$01
    STA NoteCounterSongSq1
    STA NoteCounterSongSq0
    STA NoteCounterSongTrg
    STA NoteCounterSongNoise
    LSR
    STA NoteOffsetSongSq1

KeepPlayingSong:
    DEC NoteCounterSongSq1
    BNE ApplySq1Effects
    LDY NoteOffsetSongSq1
    INC NoteOffsetSongSq1
    LDA (SongScriptPtrLo), Y
    BEQ @SongEnded
    BPL PlayNote
    BNE PrepNote

@SongEnded:
    ; If this is a song that repeats, then go play again.
    LDA Song
    AND #$F1
    BNE PlayAgain

SilenceSong:
    LDA #$00
    STA Song
    STA ApuStatus_4015
    LDA #$0F
    STA ApuStatus_4015
    RTS

PlayAgain:
    JMP PlayNextPhrase

PrepNote:
    JSR GetSongNoteLength
    STA NoteLengthSongSq1
    LDY NoteOffsetSongSq1
    INC NoteOffsetSongSq1
    LDA (SongScriptPtrLo), Y

PlayNote:
    ; If something is playing in tune channel 1, then
    ; don't play a square note here.
    LDX Tune1
    BNE @SkipSq1
    JSR EmitSquareNote1
    BEQ :+
    JSR PrepareCustomSongEnvelope
:
    STA CustomEnvelopeOffsetSongSq1
    JSR SetSq1DutyAndSweep
    LDA #$00
    STA SongVibrationCounterSq1

@SkipSq1:
    LDA NoteLengthSongSq1
    STA NoteCounterSongSq1

ApplySq1Effects:
    ; If something is playing in tune channel 1, then
    ; skip effects for square channel 1.
    LDY Tune1
    BNE @HandleSq0
    INC SongVibrationCounterSq1
    LDY CustomEnvelopeOffsetSongSq1
    BEQ :+
    DEC CustomEnvelopeOffsetSongSq1
:
    JSR ShapeSongVolume
    STA Sq1Duty_4004
    LDX #$7F
    STX Sq1Sweep_4005
    LDA Song
    BPL @HandleSq0

    ; The demo/title song ($80) vibrates the pitch.
    LDA SongVibrationCounterSq1
    LDX CurNoteLowPeriodSq1
    JSR VibratePitch
    STX Sq1Timer_4006

@HandleSq0:
    LDY NoteOffsetSongSq0
    BEQ @HandleTrg
    DEC NoteCounterSongSq0
    BNE @ApplySq0Effects
    LDY NoteOffsetSongSq0
    INC NoteOffsetSongSq0
    LDA (SongScriptPtrLo), Y
    BPL @PlaySq0
    JSR GetSongNoteLength
    STA NoteLengthSongSq0
    LDY NoteOffsetSongSq0
    INC NoteOffsetSongSq0
    LDA (SongScriptPtrLo), Y

@PlaySq0:
    LDX Tune0
    BNE @SkipSq0
    JSR EmitSquareNote0
    BEQ :+
    JSR PrepareCustomSongEnvelope
:
    STA CustomEnvelopeOffsetSongSq0
    JSR SetSq0DutyAndSweep
    LDA #$00
    STA SongVibrationCounterSq0

@SkipSq0:
    LDA NoteLengthSongSq0
    STA NoteCounterSongSq0

@ApplySq0Effects:
    LDX Tune0
    BNE @HandleTrg
    INC SongVibrationCounterSq0
    LDY CustomEnvelopeOffsetSongSq0
    BEQ :+
    DEC CustomEnvelopeOffsetSongSq0
:
    JSR ShapeSongVolume
    STA Sq0Duty_4000
    LDA Song
    BPL :+

    ; The demo/title song ($80) vibrates the pitch.
    LDA SongVibrationCounterSq0
    LDX CurNoteLowPeriodSq0
    JSR VibratePitch
    STX Sq0Timer_4002
:
    LDA #$7F
    STA Sq0Sweep_4001

@HandleTrg:
    LDA NoteOffsetSongTrg
    BNE :+
    ; Begin unverified code 1E1E
    JMP @HandleNoise
    ; End unverified code
:
    DEC NoteCounterSongTrg
    BNE @ApplyTrgEffects

@PrepNoteOrPassage:
    LDY NoteOffsetSongTrg
    INC NoteOffsetSongTrg
    LDA (SongScriptPtrLo), Y
    BEQ @SetTrgLinear
    BPL @PlayNoteTrg
    CMP #$F0
    BEQ @EndOfPassage
    BCC @PrepNoteTrg

    ; Control note >= $F1. The low nibble defines the number of
    ; repetititions of the passage starting at the next offset.
    SEC
    SBC #$F0
    STA SongRepetitionsTrg
    LDA NoteOffsetSongTrg
    STA SongRepeatStartOffset
    JMP @PrepNoteOrPassage

@EndOfPassage:
    DEC SongRepetitionsTrg
    BEQ :+
    LDA SongRepeatStartOffset
    STA NoteOffsetSongTrg
:
    JMP @PrepNoteOrPassage

@PrepNoteTrg:
    JSR GetSongNoteLength
    STA NoteLengthSongTrg
    LDA #$1F
    STA TrgLinear_4008
    LDY NoteOffsetSongTrg
    INC NoteOffsetSongTrg
    LDA (SongScriptPtrLo), Y
    BEQ @SetTrgLinear

@PlayNoteTrg:
    JSR EmitTriangleNote
    LDA #$00
    STA SongVibrationCounterTrg
    LDX NoteLengthSongTrg
    STX NoteCounterSongTrg

@ApplyTrgEffects:
    INC SongVibrationCounterTrg
    LDA SongVibrationCounterTrg
    LDX CurNoteLowPeriodTrg
    JSR VibratePitch
    STX TrgTimer_400A

    ; TODO: [05F1] ?
    LDA $05F1
    BPL :+
    LDA NTSCPAL #$1F, #$1C
    BNE @SetTrgLinear
:
    LDA #$FF

@SetTrgLinear:
    STA TrgLinear_4008

@HandleNoise:
    ; If the song is not demo nor ending, then return.
    ; They don't use noise.
    LDA Song
    AND #$91
    BEQ @Exit
    DEC NoteCounterSongNoise
    BNE @Exit
:
    LDY NoteOffsetSongNoise
    INC NoteOffsetSongNoise
    LDA (SongScriptPtrLo), Y
    BNE :+

    ; We've reached the end of the track. Noise always repeats.
    LDA FirstNoteIndexSongNoise
    STA NoteOffsetSongNoise
    BNE :-
:
    JSR GetSongNoiseNoteLength
    STA NoteCounterSongNoise

    ; From the original control note, extract an index 0-3
    ; to look up noise parameters.
    TXA
    AND #$3E
    LSR
    LSR
    LSR
    LSR
    TAY
    LDA NoiseVolumes, Y
    STA NoiseVolume_400C
    LDA NoisePeriods, Y
    STA NoisePeriod_400E
    LDA NoiseLengths, Y
    STA NoiseLength_400F

@Exit:
    RTS

NoiseVolumes:
    .BYTE $10, $1C, $1C, $1C

NoisePeriods:
    .BYTE $00, $03, $0A, $03

NoiseLengths:
    .BYTE $00, $18, $18, $58

; Params:
; A: control note
;
; Returns:
; A: note length
; X: original control note
;
; Rotate so that bits 0, 7, 6 move to bits 2, 1, 0.
;
GetSongNoiseNoteLength:
    TAX
    ROR
    TXA
    ROL
    ROL
    ROL

; Params:
; A: control note
;
; Returns:
; A: note length
;
GetSongNoteLength:
    AND #$07
    CLC
    ADC NoteLengthTableBase
    TAY
    LDA NoteLengthTable0, Y
    RTS

GetSongNoteLengthWithAbsIndex:
    ; Begin unverified code 1EF1
    AND #$07
    TAY
    LDA NoteLengthTable0, Y
    RTS
    ; End unverified code

; Unknown block
    .BYTE $CB

StairsSfxNotes:
    .BYTE $0E, $0E, $4C, $6D, $8C, $CD

; Big-endian 16-bit period values.
    .ALIGN 256
NotePeriodTable:
.IFNDEF PAL
    .BYTE $00, $23, $00, $6A, $03, $27, $00, $97
    .BYTE $00, $00, $02, $F9, $02, $CF, $02, $A6
    .BYTE $02, $80, $02, $5C, $02, $3A, $02, $1A
    .BYTE $01, $FC, $01, $DF, $01, $C4, $01, $AB
    .BYTE $01, $93, $01, $7C, $01, $67, $01, $53
    .BYTE $01, $40, $01, $2E, $01, $1D, $01, $0D
    .BYTE $00, $FE, $00, $EF, $00, $E2, $00, $D5
    .BYTE $00, $C9, $00, $BE, $00, $B3, $00, $A9
    .BYTE $00, $A0, $00, $8E, $00, $86, $00, $77
    .BYTE $00, $7E, $00, $71, $00, $54, $00, $64
    .BYTE $00, $5F, $00, $59, $00, $50, $00, $47
    .BYTE $00, $43, $00, $3F, $00, $38, $00, $32
    .BYTE $00, $21, $05, $4D, $05, $01, $04, $B9
    .BYTE $04, $35, $03, $F8, $03, $BF, $03, $89
    .BYTE $03, $57
.ELSE
    .BYTE $00, $23, $00, $62, $02, $E8, $00, $8B
    .BYTE $00, $00, $02, $BE, $02, $98, $02, $72
    .BYTE $02, $4F, $02, $2E, $02, $0E, $01, $F1
    .BYTE $01, $D4, $01, $BA, $01, $A1, $01, $8A
    .BYTE $01, $74, $01, $5F, $01, $4B, $01, $39
    .BYTE $01, $27, $01, $17, $01, $07, $00, $F8
    .BYTE $00, $EA, $00, $DD, $00, $D1, $00, $C5
    .BYTE $00, $BA, $00, $AF, $00, $A5, $00, $9C
    .BYTE $00, $94, $00, $83, $00, $7C, $00, $6E
    .BYTE $00, $74, $00, $68, $00, $4E, $00, $5C
    .BYTE $00, $58, $00, $52, $00, $4A, $00, $42
    .BYTE $00, $3E, $00, $3A, $00, $34, $00, $2E
    .BYTE $00, $1F, $04, $E4, $04, $9E, $04, $5C
    .BYTE $03, $E2, $03, $A9, $03, $75, $03, $43
    .BYTE $03, $15
.ENDIF

; Returns:
; A: starting custom envelope offset
; X: duty byte $82
; Y: sweep byte $7F
;
PrepareCustomSongEnvelope:
    LDA SongEnvelopeSelector
    LDA #$20
    LDX #$82
    LDY #$7F
    RTS

; Params:
; Y: envelope offset
;
; Returns:
; A: duty/volume value
;
ShapeSongVolume:
    LDA SongEnvelopeSelector
    BPL :+
    LDA CustomEnvelopeSong, Y
    AND #$0F
    BNE @ReturnValue
:
    LDA CustomEnvelopeSong, Y
    LSR
    LSR
    LSR
    LSR

@ReturnValue:
    ORA #$90
    RTS

CustomEnvelopeSong:
    .BYTE $04, $24, $24, $34, $34, $35, $35, $35
    .BYTE $45, $45, $46, $46, $46, $46, $46, $46
    .BYTE $46, $46, $57, $57, $57, $57, $68, $68
    .BYTE $68, $68, $79, $79, $79, $68, $68, $57

SwordSfxNotes:
    .BYTE $47, $67, $87, $A8, $B9, $9A, $8A, $5A
    .BYTE $9B, $8B

ArrowSfxNotes:
    .BYTE $FB, $F9, $9D, $6E, $3F

FlameSfxNotes:
    .BYTE $1A, $1A, $1C, $1D, $1D, $1E, $1E, $1F
    .BYTE $1F, $1E, $1A, $19, $16, $13, $11, $11

.IFNDEF PAL
NoteLengthTable0:
    .BYTE $03, $0A, $01, $14, $05, $28, $3C, $70

NoteLengthTable1:
    .BYTE $07, $1B, $35, $14, $0D, $28, $3C, $50

NoteLengthTable2:
    .BYTE $06, $0C, $08, $18, $24, $30, $48, $10

NoteLengthTable3:
    .BYTE $07, $0D, $09, $1B, $24, $36, $48, $10

NoteLengthTable4:
    .BYTE $3C, $50, $0A, $05, $14, $0D, $28, $0E
.ELSE
NoteLengthTable0:
    .BYTE $02, $08, $01, $10, $05, $20, $30, $40

NoteLengthTable1:
    .BYTE $04, $14, $2C, $10, $0C, $20, $30, $40

NoteLengthTable2:
    .BYTE $05, $0A, $07, $14, $1E, $28, $3C, $06

NoteLengthTable3:
    .BYTE $05, $0A, $07, $14, $1E, $28, $3C, $0D

NoteLengthTable4:
    .BYTE $30, $40, $08, $04, $10, $0B, $20, $0A
.ENDIF

.SEGMENT "BANK_00_ISR"
.INCLUDE "Reset.inc"

.SEGMENT "BANK_00_VEC"
.IMPORT IsrNmi
    .ADDR IsrNmi, IsrReset, *&$FFF0
