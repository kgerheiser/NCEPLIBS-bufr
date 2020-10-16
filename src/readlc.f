C> @file
C> @author WOOLLEN @date 2003-11-04
      
C> THIS SUBROUTINE RETURNS A CHARACTER DATA ELEMENT ASSOCIATED
C>   WITH A PARTICULAR SUBSET MNEMONIC FROM THE INTERNAL MESSAGE BUFFER
C>   (ARRAY MBAY IN MODULE BITBUF).  IT IS DESIGNED TO BE USED TO RETURN
C>   CHARACTER ELEMENTS GREATER THAN THE USUAL LENGTH OF EIGHT BYTES.
C>
C> PROGRAM HISTORY LOG:
C> 2003-11-04  J. WOOLLEN -- ORIGINAL AUTHOR
C> 2003-11-04  D. KEYSER  -- UNIFIED/PORTABLE FOR WRF; ADDED
C>                           DOCUMENTATION; OUTPUTS MORE COMPLETE
C>                           DIAGNOSTIC INFO WHEN ROUTINE TERMINATES
C>                           ABNORMALLY OR UNUSUAL THINGS HAPPEN
C> 2004-08-09  J. ATOR    -- MAXIMUM MESSAGE LENGTH INCREASED FROM
C>                           20,000 TO 50,000 BYTES
C> 2007-01-19  J. ATOR    -- REPLACED CALL TO PARSEQ WITH CALL TO PARSTR
C> 2009-03-23  J. ATOR    -- ADDED CAPABILITY FOR COMPRESSED MESSAGES;
C>                           ADDED CHECK FOR OVERFLOW OF CHR; ADDED '#'
C>                           OPTION FOR MORE THAN ONE OCCURRENCE OF STR
C> 2009-04-21  J. ATOR    -- USE ERRWRT
C> 2012-12-07  J. ATOR    -- ALLOW STR MNEMONIC LENGTH OF UP TO 14 CHARS
C>                           WHEN USED WITH '#' OCCURRENCE CODE
C> 2014-12-10  J. ATOR    -- USE MODULES INSTEAD OF COMMON BLOCKS
C>
C> USAGE:    CALL READLC (LUNIT, CHR, STR)
C>   INPUT ARGUMENT LIST:
C>     LUNIT    - INTEGER: FORTRAN LOGICAL UNIT NUMBER FOR BUFR FILE
C>     STR      - CHARACTER*(*): STRING (I.E., MNEMONIC)
C>
C>   OUTPUT ARGUMENT LIST:
C>     CHR      - CHARACTER*(*): UNPACKED CHARACTER STRING (I.E.,
C>                CHARACTER DATA ELEMENT GREATER THAN EIGHT BYTES)
C>
C> REMARKS:
C>    THIS ROUTINE CALLS:        BORT     ERRWRT   PARSTR   PARUTG
C>                               STATUS   UPC
C>    THIS ROUTINE IS CALLED BY: UFBDMP   UFDUMP   WRTREE
C>                               Also called by application programs.
C>
      SUBROUTINE READLC(LUNIT,CHR,STR)



      USE MODA_USRINT
      USE MODA_USRBIT
      USE MODA_UNPTYP
      USE MODA_BITBUF
      USE MODA_TABLES
      USE MODA_RLCCMN

      INCLUDE 'bufrlib.prm'

      COMMON /QUIET / IPRT

      CHARACTER*(*) CHR,STR
      CHARACTER*128 BORT_STR,ERRSTR
      CHARACTER*10  CTAG
      CHARACTER*14  TGS(10)

      DATA MAXTG /10/

C-----------------------------------------------------------------------
C-----------------------------------------------------------------------

      CHR = ' '

C  CHECK THE FILE STATUS
C  ---------------------

      CALL STATUS(LUNIT,LUN,IL,IM)
      IF(IL.EQ.0) GOTO 900
      IF(IL.GT.0) GOTO 901
      IF(IM.EQ.0) GOTO 902

C  CHECK FOR TAGS (MNEMONICS) IN INPUT STRING (THERE CAN ONLY BE ONE)
C  ------------------------------------------------------------------

      CALL PARSTR(STR,TGS,MAXTG,NTG,' ',.TRUE.)
      IF(NTG.GT.1) GOTO 903

C     Check if a specific occurrence of the input string was requested;
C     if not, then the default is to return the first occurrence.

      CALL PARUTG(LUN,0,TGS(1),NNOD,KON,ROID)
      IF(KON.EQ.6) THEN
         IOID=NINT(ROID)
         IF(IOID.LE.0) IOID = 1
         CTAG = ' '
         II = 1
         DO WHILE((II.LE.10).AND.(TGS(1)(II:II).NE.'#'))
            CTAG(II:II)=TGS(1)(II:II)
            II = II + 1
         ENDDO
      ELSE
         IOID = 1
         CTAG = TGS(1)(1:10)
      ENDIF

C  LOCATE AND DECODE THE LONG CHARACTER STRING
C  -------------------------------------------

      IF(MSGUNP(LUN).EQ.0.OR.MSGUNP(LUN).EQ.1) THEN

C        The message is uncompressed

         ITAGCT = 0
         DO N=1,NVAL(LUN)
           NOD = INV(N,LUN)
           IF(CTAG.EQ.TAG(NOD)) THEN
             ITAGCT = ITAGCT + 1
             IF(ITAGCT.EQ.IOID) THEN
               IF(ITP(NOD).NE.3) GOTO 904
               NCHR = NBIT(N)/8
               IF(NCHR.GT.LEN(CHR)) GOTO 905
               KBIT = MBIT(N)
               CALL UPC(CHR,NCHR,MBAY(1,LUN),KBIT,.TRUE.)
               GOTO 100
             ENDIF
           ENDIF
         ENDDO
      ELSEIF(MSGUNP(LUN).EQ.2) THEN

C        The message is compressed

         IF(NRST.GT.0) THEN
           ITAGCT = 0
           DO II=1,NRST
             IF(CTAG.EQ.CRTAG(II)) THEN
               ITAGCT = ITAGCT + 1
               IF(ITAGCT.EQ.IOID) THEN
                 NCHR = IRNCH(II)
                 IF(NCHR.GT.LEN(CHR)) GOTO 905
                 KBIT = IRBIT(II)
                 CALL UPC(CHR,NCHR,MBAY(1,LUN),KBIT,.TRUE.)
                 GOTO 100
               ENDIF
             ENDIF
           ENDDO
         ENDIF
      ELSE
         GOTO 906
      ENDIF

C     If we made it here, then we couldn't find the requested string.

      IF(IPRT.GE.0) THEN
      CALL ERRWRT('++++++++++++++BUFR ARCHIVE LIBRARY+++++++++++++++++')
      ERRSTR = 'BUFRLIB: READLC - MNEMONIC ' // TGS(1) //
     .   ' NOT LOCATED IN REPORT SUBSET - RETURN WITH BLANK' //
     .   ' STRING FOR CHARACTER DATA ELEMENT'
      CALL ERRWRT(ERRSTR)
      CALL ERRWRT('++++++++++++++BUFR ARCHIVE LIBRARY+++++++++++++++++')
      CALL ERRWRT(' ')
      ENDIF

C  EXITS
C  -----

100   RETURN
900   CALL BORT('BUFRLIB: READLC - INPUT BUFR FILE IS CLOSED, IT MUST'//
     . ' BE OPEN FOR INPUT')
901   CALL BORT('BUFRLIB: READLC - INPUT BUFR FILE IS OPEN FOR '//
     . 'OUTPUT, IT MUST BE OPEN FOR INPUT')
902   CALL BORT('BUFRLIB: READLC - A MESSAGE MUST BE OPEN IN INPUT '//
     . 'BUFR FILE, NONE ARE')
903   WRITE(BORT_STR,'("BUFRLIB: READLC - THERE CANNOT BE MORE THAN '//
     . 'ONE MNEMONIC IN THE INPUT STRING (",A,") (HERE THERE ARE ",'//
     . 'I3,")")') STR,NTG
      CALL BORT(BORT_STR)
904   WRITE(BORT_STR,'("BUFRLIB: READLC - MNEMONIC ",A," DOES NOT '//
     . 'REPRESENT A CHARACTER ELEMENT (ITP=",I2,")")') TGS(1),ITP(NOD)
      CALL BORT(BORT_STR)
905   WRITE(BORT_STR,'("BUFRLIB: READLC - MNEMONIC ",A," IS A '//
     . 'CHARACTER STRING OF LENGTH",I4," BUT SPACE WAS PROVIDED '//
     . 'FOR ONLY",I4, " CHARACTERS")') TGS(1),NCHR,LEN(CHR)
      CALL BORT(BORT_STR)
906   WRITE(BORT_STR,'("BUFRLIB: READLC - MESSAGE UNPACK TYPE",I3,'//
     . '" IS NOT RECOGNIZED")') MSGUNP
      CALL BORT(BORT_STR)
      END
