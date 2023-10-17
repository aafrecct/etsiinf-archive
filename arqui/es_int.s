        ORG     $400
* DIRECCIONES Y OTROS DATOS
* Nombres de los registros de la DUART.
* Registros de la linea A.
*    Modo (MRA)
*    Estado (SRA) / Selección de Reloj.
*    Control (CRA)
*    Buffer (BFA) Trasmisión/Recepción.
MRA     EQU     $effc01
SRA     EQU     $effc03
CRA     EQU     $effc05
BFA     EQU     $effc07
* Registros de la linea B.
MRB     EQU     $effc11
SRB     EQU     $effc13
CRB     EQU     $effc15
BFB     EQU     $effc17
* Comunes.
*    Control Auxiliar.
*    Estado/Mascara de Interrupción.
*    Vector de Interrupción.
ACR     EQU     $effc09
IR      EQU     $effc0B
IVR     EQU     $effc19 

* Caracteres de nueva linea.
CR      EQU     $0D
LR      EQU     $0A  


* >---------------------------<
* RTI
* >---------------------------<
RTI:
* Guardamos estado.
        link    A6,#-16
        move.l  D0,-4(A6)
        move.l  D1,-8(A6)   
        move.l  A0,-12(A6)
        move.l  A1,-16(A6)   
* Lectura de Estado de Interrupción.
        move.l  #0,D0
        move.b  IR,D0
        move.b  IMRlw,D1
        and.b   D1,D0
* Veamos si es de Trasmisión o Recepción
        move.l  D0,D1
        and.l   #$00000011,D1
        cmp.b   #0,D1
        bne     TItran
* La DUART esta preparada para Recepcion.
TIrecp  and.l   #$00000022,D0
        cmp     #4,D0
        bpl     TIrecb
TIreca  move.b  BFA,D1
        move.l  #%00,D0
        bra     TIrecc
TIrecb  move.b  BFB,D1
        move.l  #%01,D0
TIrecc  jsr     ESCCAR
TIrece  bra     TIend
* La DUART esta preparada para Trasmisión.
TItran  and.l   #$00000011,D0
        cmp     #4,D0
        bpl     TItrab
TItraa  move.l  #%10,D0
        jsr     LEECAR
        move.b  #%00000001,D1
        cmp     #$FFFFFFFF,D0
        beq     TItrac
        move.b  D0,BFA
        bra     TIend
TItrab  move.l  #%11,D0
        jsr     LEECAR
        move.b  #%00010000,D1
        cmp     #$FFFFFFFF,D0
        beq     TItrac
        move.b  D0,BFB
        bra     TIend
TItrac  move.b  IMRlw,D0
        eor.b   D0,D1
        move.b  D1,IMRlw
        move.b  D1,IR
* Se recupera el estado y la pila.
TIend   move.l  -4(A6),D0
        move.l  -8(A6),D1
        move.l  -12(A6),A0
        move.l  -16(A6),A1
        unlk    A6
        rte


* >---------------------------<
* INIT
* Configura la comunicación con la Dual UART.
* >---------------------------<
INIT:
* Resetamos para acceso a MR1.
        move.b  #%00010000,CRA
        move.b  #%00010000,CRB
* Mascara de interrupción
        move.b  #%00100010,IR
        move.b  #%00100010,IMRlw
* Caracteres de 1 byte.
* Interrupcion por cada caracter.
        move.b  #%00000011,MRA
        move.b  #%00000011,MRB
* Activamos trasmision y recepción
        move.b  #%00000101,CRA
        move.b  #%00000101,CRB
* Acceso a MR2. No eco.
        move.b  #%00000000,MRA
        move.b  #%00000000,MRB
* Velocidad = 38400bps.
        move.b  #%00000000,ACR
        move.b  #%11001100,SRA
        move.b  #%11001100,SRB
* Vector de interrupción
        move.b  #$40,IVR
* Actualizar tabla de vectores de interrupción
        move.l  #RTI,$100
* Incicializar Buffers
*       IRBA
        move.w  #0,IRBAi
        move.w  #0,IRBAe
        move.w  #2,IRBAf
*       IRBB
        move.w  #0,IRBBi
        move.w  #0,IRBBe
        move.w  #2,IRBBf
*       ITBA
        move.w  #0,ITBAi
        move.w  #0,ITBAe
        move.w  #2,ITBAf
*       ITBB
        move.w  #0,ITBBi
        move.w  #0,ITBBe
        move.w  #2,ITBBf
        rts


* >---------------------------<
* SCAN
* Lee un número de bytes de uno de los 
* buffers internos de recepción.
* En Pila:
*   - Buffer destino (Dirección)
*   - Linea (A | B)
*   - Tamaño (N. de bytes)
* >---------------------------<
SCAN:   
* Obtención de destino y tamaño.
        link    A6,#-4
        move.l  #0,D0
        move.l  8(A6),A0
        move.w  14(A6),D0
        move.l  A0,A1
        adda.l  D0,A1
* Dirección final al marco de pila
        move.l  A1,-4(A6)
* Bucle hasta que Dir.actual = Dir.Final
SCloop  cmp     A0,A1
        beq     SClend
* Comprobación: ID de linea es valido
        move.w  12(A6),D0
        move.l  D0,D1
        and.l   #$0000FFFE,D1
        cmp     #0,D1
        beq     SCnoer
* Hay error.
        move.l  #$FFFFFFFF,D0
        bra     SCsend
* No hay error. Escritura de caracter.
SCnoer  bsr     LEECAR
        move.l  8(A6),A0
        cmp     #$FFFFFFFF,D0
        bne     SCVtoB
        jmp     SClend
SCVtoB  move.b  D0,(A0)+
        move.l  A0,8(A6)
        move.l  -4(A6),A1
        jmp     SCloop
* Calcular caracteres leidos.
SClend  move.l  -4(A6),D0
        sub.l   8(A6),D0
        sub.w   14(A6),D0
        neg.w   D0 
SCsend  unlk    A6
        rts


* >---------------------------<
* PRINT 
* Escribe un número de bytes en uno de los 
* buffers internos de trasmisión.
* En Pila:
*   - Buffer origen (Dirección)
*   - Linea (A | B)
*   - Tamaño (N. de bytes)
* >---------------------------<
PRINT:
* Obtención de destino y tamaño.
        link    A6,#-4
        move.l  #0,D0
        move.l  8(A6),A0
        move.w  14(A6),D0
        move.l  A0,A1
        adda.l  D0,A1
* Dirección final al marco de pila
        move.l  A1,-4(A6)
* Bucle hasta que Dir.actual = Dir.Final
PRloop  cmp     A0,A1
        beq     PRlend
* Comprobación: ID de linea es valido
        move.w  12(A6),D0
        move.l  D0,D1
        and.l   #$0000FFFE,D1
        cmp     #0,D1
        beq     PRnoer
* Hay error.
        move.l  #$FFFFFFFF,D0
        bra     PRsend
* No hay error.
PRnoer  add.l   #2,D0
        move.l  8(A6),A1
        add.l   #1,8(A6)
        move.b  (A1),D1
* Escritura de caracter.
        jsr     ESCCAR
        cmp     #$FFFFFFFF,D0
        bne     PRrest
        jmp     PRlend
* Error en escritura de caracter
PRrest  move.l  8(A6),A0
        move.l  -4(A6),A1
        bra     PRloop
* Encender Mascara de Interrupción correspondiente.
PRlend  move.b  IMRlw,D1
        move    12(A6),D0
        btst    #0,D0
        bne     PRmdlb
        or.b    #%00000001,D1
        bra     PRsimr
PRmdlb  or.b    #%00010000,D1      
PRsimr  move.w  #$2700,SR
        move.b  D1,IR
        move.b  D1,IMRlw
        move.w  #$2000,SR
* Calcular caracteres escritos.
        move.l  -4(A6),D0
        sub.l   8(A6),D0
        sub.w   14(A6),D0
        neg.w   D0 
PRsend  unlk    A6
        rts


* >---------------------------<
* LEECAR
* Lee del registro de buffer del parametro (en D0).
* Devuelve en D0 el código del caracter leído.
* >---------------------------<
LEECAR: 
* Elección de buffer interno.
        lea     IRBA,A0
        and.l   #$3,D0
        mulu    #2006,D0
        adda.l  D0,A0
* Dirección del puntero de extracción
        move.l  A0,A1
        adda.l  #2002,A1
* Comprobar si FIFO vacía.
        move.w  2(A1),D0
        btst    #1,D0
        bne     LCbadr
* Leer caracter.
        move.w  (A1),D0
        adda.l  D0,A0
        move.l  #0,D0
        move.b  (A0),D0
* Sumar 1 al puntero de extraccion.
        add.w   #1,(A1)
        cmp     #2000,(A1)
        bne     LCfcmp
        move.w  #0,(A1)
* Comprobamos si se ha vaciado la FIFO  
LCfcmp  move.w  (A1),D1
        cmp.w   -2(A1),D1
        bne     LCnote
        move.w  #2,2(A1)
        bra     LCexit
LCnote  move.w  #0,2(A1)
        bra     LCexit
* Se ha vaciado la FIFO.
* Algo ha ido mal.
LCbadr  move.l  #$FFFFFFFF,D0
* Salimos de la subrutina.
LCexit  rts


* >---------------------------<
* ESCCAR 
* Escribe el contenido de D1 en el registro de buffer del parametro (en D0).
* Si la pila esta llena, devuelve $FFFFFFFF en D0
* >---------------------------<
ESCCAR: 
* Elección de buffer interno.
        lea     IRBA,A0
        and.l   #$3,D0
        mulu    #2006,D0
        adda.l  D0,A0
* Dirección del puntero
        move.l  A0,A1
        adda.l  #2000,A1
* Comprobar si FIFO llena.
        move.w  4(A1),D0
        btst    #0,D0
        bne     ECbadr
* Añadir caracter.
        move.w  (A1),D0
        adda.l  D0,A0
        move.b  D1,(A0)
        move.l  #0,D0
* Sumar uno al puntero de insercion
        add.w   #1,(A1)
        cmp     #2000,(A1)
        bne     ECfcmp
        move    #0,(A1)
* Comprobamos si fifo llena.
ECfcmp  move.w  2(A1),D1
        cmp.w   (A1),D1
        bne     ECnotf
        move.w  #1,4(A1)
        bra     ECexit
ECnotf  move.w  #0,4(A1)
        bra     ECexit
* Algo ha ido mal.
ECbadr  move.l  #$FFFFFFFF,D0
* Salimos de la subrutina.
ECexit  rts


* Bufferes Internos
* i -> Insertion pointer
* e -> Extraction pointer
* f -> Fullness indicator
        ORG     $4000
BFSIZE  EQU     2000
* Internal Reception Buffer for line A (00)
IRBA    DS.B    BFSIZE
IRBAi   DC.W    0
IRBAe   DC.W    0
IRBAf   DC.W    2
* Internal Reception Buffer for line B (01)
IRBB    DS.B    BFSIZE
IRBBi   DC.W    0
IRBBe   DC.W    0
IRBBf   DC.W    2
* Internal Transmision Buffer for line A (10)
ITBA    DS.B    BFSIZE
ITBAi   DC.W    0
ITBAe   DC.W    0
ITBAf   DC.W    2
* Internal Transmision Buffer for line B (11)
ITBB    DS.B    BFSIZE
ITBBi   DC.W    0
ITBBe   DC.W    0
ITBBf   DC.W    2
* Ultima escritura del la mascara de interrumpcion.
IMRlw   DC.B    %00000000   

* PWEBWAS UwU
        ORG     $0
        DC.L    $8000
        DC.L    BEGIN

        ORG     $1200
BUFFER  DS.B    2100
PARDIR  DC.L    0
PARTAM  DC.L    0
CONTC   DC.L    0
DESA    EQU     0
DESB    EQU     1
TAMBS   EQU     1000
TAMBP   EQU     1000

BEGIN:  move.l  #BUSERR,8
        move.l  #ADDERR,12
        move.l  #ILLINS,16
        move.l  #PRIVVI,32
        move.l  #ILLINS,40
        move.l  #ILLINS,44
        move.l  #$8000,A7

        jsr     INIT
        move.w  #$2000,SR        
BUCPR   move.w  #TAMBS,PARTAM
        move.l  #BUFFER,PARDIR
OTRAL   move.w  PARTAM,-(A7)
        move.w  #DESA,-(A7)
        move.l  PARDIR,-(A7)
ESPL    jsr     SCAN
        add.l   #8,A7
        add.l   D0,PARDIR
        sub.w   D0,PARTAM
        bne     OTRAL
        
        move.w  #TAMBS,CONTC
        move.l  #BUFFER,PARDIR
OTRAE   move.w  #TAMBP,PARTAM
ESPE    move.w  PARTAM,-(A7)
        move.w  #DESA,-(A7)
        move.l  PARDIR,-(A7)
        jsr     PRINT
        add.l   #8,A7
        move.w  PARTAM,-(A7)
        move.w  #DESB,-(A7)
        move.l  PARDIR,-(A7)
        jsr     PRINT
        add.l   #8,A7
        add.l   D0,PARDIR
        sub.w   D0,CONTC
        beq     SALIR
        sub.w   D0,PARTAM
        bne     ESPE
        cmp.w   #TAMBP,CONTC
        bhi     OTRAE
        move.w  CONTC,PARTAM
        bra     ESPE

SALIR   bra BUCPR

BUSERR  BREAK
        NOP
ADDERR  BREAK
        NOP
ILLINS  BREAK
        NOP
PRIVVI  BREAK
        NOP
Fin     rts
END
