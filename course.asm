
.386

DATA SEGMENT USE16
    OUTPUT1 DB '1.insert scores',0AH,0DH,'$'
    OUTPUT2 DB '2.search scores',0AH,0DH,'$'
    SELECTONEMESSAGE DB 0AH,0DH,'SELECT ONE, Please input No.,Name,Score; in this formate',0AH,0DH,'$'
    SELECTTWOMESSAGE DB 0AH,0DH,'SELEC TWO , Please input No.; in this formate',0AH,0DH,'$'
    BACKHOMEMESSAGE DB 0AH,0DH,'ENTER RETURN, Now back home',0AH,0DH,'$'

    ERROROUTPUT DB 0AH,0DH,'ERROR:INPUT WRONG',0AH,0DH,'$'
    ERRORINSERTFULL DB 0AH,0DH,'WARNING: Reached maxed number of students!',0AH,0DH,'$'
    NOINPUTMESSAGE DB 0AH,0DH,'ERROR: Unexpected finished input without all three data inputed!',0AH,0DH,'$'
    ERRORTYPEFULL DB 0AH,0DH,'WARNING: Reached maxed number of Characters! ANY Characters behind wont be recognized',0AH,0DH,'$'

    NOTFOUNDMESSAGE DB ' NOT FOUND!',0AH,0DH,'$'
    LOOPINPUTSPACE DB ' ','$'
    BACKSPACE DB 0AH,0DH,'$'

    SELECTED DB ?
    INPUTBUF DB 20 DUP(0)
    STUDENTDATA DB 20 DUP(20 DUP(0) , 20 DUP(0), 20 DUP(0))
    INPUTCOUNT DW 0
    INPUTLINE DW 0
    INPUTPARAMETERCOUNT DW 0
DATA ENDS

STACK0 SEGMENT USE16 STACK
    DB 200 DUP(0)
STACK0 ENDS

CODE SEGMENT USE16
    ASSUME CS:CODE,DS:DATA,ES:DATA,SS:STACK0
    BEGIN: 
        MOV AX,DATA
        MOV DS,AX
        MOV ES,AX

        MOV DX,OFFSET OUTPUT1
        MOV AH,9
        INT 21H

        MOV DX,OFFSET OUTPUT2
        MOV AH,9
        INT 21H

        ;此处完成了输出两个选项的锅
        
        GETOPTION:
            MOV AH,1
            INT 21H
        
            CMP AL,'1'
            JE SELECTONE

            CMP AL,'2'
            JE SELECTTWO

            CMP AL,'Q'
            JE EXIT
            
            MOV DX,OFFSET ERROROUTPUT
            MOV AH,9
            INT 21H
            
            JMP GETOPTION
        ;此处完成了选择一个选项的锅

        SELECTONE:
            
            MOV DX,OFFSET SELECTONEMESSAGE
            MOV AH,9
            INT 21H
            
            JMP INPUTDATA

        SELECTTWO:
            
            MOV DX,OFFSET SELECTTWOMESSAGE
            MOV AH,9
            INT 21H

            JMP SEARCHDATA


        EXIT:
            MOV AH,4CH
            INT 21H

        INPUTDATA:
            START: 
                LEA BX,INPUTBUF
                MOV INPUTCOUNT,0
                MOV INPUTLINE,0
                MOV INPUTPARAMETERCOUNT,0
            BEG:
                LEA DI,STUDENTDATA
                MOV CX,0
            NEXT0:

                MOV AH,1
                INT 21H
                ;获取1个输入
                CMP AL,'Q'
                JE EXIT
                ;Q则退出
                CMP AL,0DH
                JE BACKHOME
                ;如果是回车，回到主选单
                CMP AL,','
                JE DIGIT
                ;如果是 , 则跳转单个输入完成
                CMP AL,';'
                JNE NORMALINPUT
                ;如果不是;，前往正常输入
                CMP INPUTPARAMETERCOUNT,2
                JNE NOINPUT
                ;如果是;但是没输入正确，跳转错误输入
                JMP DIGIT
                ;是;，输入正确

            MAXINPUTININSERT:

                LEA DX,ERRORTYPEFULL
                MOV AH,9
                INT 21H

                JMP NEXT0

            NORMALINPUT:

                MOV CL,AL
                MOV AX,[INPUTCOUNT]
                CMP AX,19
                JE MAXINPUTININSERT

                MOV BX,0
                
                ADD BX,[INPUTCOUNT]
                MOV INPUTBUF[BX],CL
                INC INPUTCOUNT

                JMP NEXT0
            DIGIT:
                CMP INPUTPARAMETERCOUNT,0
                JE INPUTP
                CMP INPUTPARAMETERCOUNT,1
                JE INPUTP
                CMP INPUTPARAMETERCOUNT,2
                JE INPUTP
            INPUTP:

                LEA SI,INPUTBUF

                MOV BX,0
                
                ADD BX,[INPUTCOUNT]
                
                MOV INPUTBUF[BX],'$'
                ;在尾部写入$

                
                MOV AX,[INPUTLINE]
                IMUL AX,60
                MOV BX,AX
                MOV AX,[INPUTPARAMETERCOUNT]
                IMUL AX,20
                ADD BX,AX
                LEA DI,STUDENTDATA[BX]
                ;寻址

                MOV AX,[INPUTCOUNT]
                MOV CX,AX
                CLD
                REP MOVSB     
                ;串复制

                ADD BX,[INPUTCOUNT]
                MOV STUDENTDATA[BX],'$'
                ;复制完在尾部加结束符号


                MOV INPUTCOUNT,0                  

                INC INPUTPARAMETERCOUNT

                CMP INPUTPARAMETERCOUNT,3
                JE NEWLINE
                JNE NEXT0
                ;如果已经输入了3个，就新一行
            
            NEWLINE:
                MOV INPUTPARAMETERCOUNT,0
                INC INPUTLINE
                MOV INPUTCOUNT,0

                MOV DL,0DH
                MOV AH,2
                INT 21H

                MOV AX,INPUTLINE
                CMP AX,10
                JL NEXT0
                JMP ENDINPUT
                ;进入新的一行
            NOINPUT:
                MOV AX,DATA
                MOV DS,AX
    
                MOV DX,OFFSET NOINPUTMESSAGE
                MOV AH,9
                INT 21H
                MOV DL,0AH
                MOV AH,2
                INT 21H
                
                MOV INPUTCOUNT,0
                MOV INPUTPARAMETERCOUNT,0
                JMP NEXT0
                ;输入错误，重新输入这一条
            
            ENDINPUT:

                MOV AX,DATA
                MOV DS,AX
    
                MOV DX,OFFSET ERRORINSERTFULL
                MOV AH,9
                INT 21H
                MOV DL,0AH
                MOV AH,2
                INT 21H

                JMP BEGIN
                ;输完了10个，回到主页


        SEARCHDATA:
            BEG2:
                MOV INPUTCOUNT,0
            INPUTSEARCHDATA:
                MOV AH,1
                INT 21H
                ;获取1个输入
                CMP AL,'Q'
                JE EXIT
                ;Q则退出
                CMP AL,0DH
                JE BACKHOME
                ;如果是回车，回到主选单
                CMP AL,';'
                JNE SEARCHNORMALINPUT
                ;如果不是;，前往正常输入
                JE SEARCHINARRAYSTART

            MAXINPUTINSEARCH:
                LEA DX,ERRORTYPEFULL
                MOV AH,9
                INT 21H

                JMP INPUTSEARCHDATA

            SEARCHNORMALINPUT:

                MOV CL,AL
                MOV AX,[INPUTCOUNT]
                CMP AX,19
                JE MAXINPUTINSEARCH
                
                MOV BX,0
                
                ADD BX,[INPUTCOUNT]
                MOV INPUTBUF[BX],CL
                INC INPUTCOUNT

                JMP INPUTSEARCHDATA

            SEARCHINARRAYSTART:
                MOV CX,10
                ;循环10次
                JMP SEARCHINARRAYLOOP
                
            SEARCHINARRAYLOOP:

                INITFINDINDEX:
                    MOV DX,0

                FINDDATA:

                    MOV AX,CX
                    DEC AX
                    IMUL AX,60
                    MOV BX,AX
                    LEA DI,STUDENTDATA[BX]
                    ;寻址
                
                
                FINDCHARATER:
                    MOV AX,DX
                    
                    MOV BX,AX
                    LEA BX,INPUTBUF[BX]
                    MOV AL,[BX]
                    SCASB
                    JE FITONCE
                    ;找到则继续下一个
                    JMP NOTFOUNDONCE
                    ;没找到则看看下个串
                

                FITONCE:
                    INC DX
                    MOV AX,[INPUTCOUNT]
                    CMP DX,AX
                    JE FOUNDIT
                    ;找到了则跳转结束
                    JMP FINDCHARATER
                    ;没找完，继续下一个

            NOTFOUNDONCE:
                    
                DEC CX
                CMP CX,0
                JNE SEARCHINARRAYLOOP
                ;未循环完，回去
                JMP ALLNOTFOUND
                ;全都没找到，转向没找到

            FOUNDIT:
                INITPRINTPLACE:

                    LEA DX,BACKSPACE
                    MOV AH,9
                    INT 21H

                    MOV AX,CX
                    DEC AX
                    MOV INPUTLINE,AX
                    MOV CX,3

                LOOPPRINT:

                    MOV AX,[INPUTLINE]
                    IMUL AX,60
                    MOV BX,AX
                    MOV DX,CX
                    MOV AX,3
                    SUB AX,DX
                    IMUL AX,20
                    ADD BX,AX
                    LEA DX,STUDENTDATA[BX]
                    ;寻址

                    MOV AH,9
                    INT 21H

                    LEA DX,LOOPINPUTSPACE
                    MOV AH,9
                    INT 21H
                    ;输出空格

                ISLOOPFINISHED:
                    DEC CX
                    CMP CX,0
                    JNE LOOPPRINT

                    LEA DX,BACKSPACE
                    MOV AH,9
                    INT 21H

                    JMP SEARCHDATA

            ALLNOTFOUND:
                MOV AX,DATA
                MOV DS,AX
                MOV DX,OFFSET NOTFOUNDMESSAGE
                MOV AH,9
                INT 21H
                JMP SEARCHDATA

        BACKHOME:
            LEA DX,BACKHOMEMESSAGE
            MOV AH,9
            INT 21H
            JMP BEGIN

            
CODE ENDS
    END BEGIN