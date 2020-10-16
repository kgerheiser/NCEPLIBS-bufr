C> @file
C> @author WOOLLEN @date 1994-01-06
      
C> THIS SUBROUTINE WRITES OVER SPECIFIED VALUES WHICH EXIST
C>   IN CURRENT INTERNAL BUFR SUBSET ARRAYS IN A FILE OPEN FOR OUTPUT.
C>   THE DATA VALUES CORRESPOND TO MNEMONICS WHICH ARE PART OF A
C>   DELAYED-REPLICATION SEQUENCE, OR FOR WHICH THERE IS NO REPLICATION
C>   AT ALL.  EITHER BUFR ARCHIVE LIBRARY SUBROUTINE OPENMG OR OPENMB
C>   MUST HAVE BEEN PREVIOUSLY CALLED TO OPEN AND INITIALIZE A BUFR
C>   MESSAGE WITHIN MEMORY FOR THIS LUNIT.  IN ADDITION, BUFR ARCHIVE
C>   LIBRARY SUBROUTINE WRITSB OR INVMRG MUST HAVE BEEN CALLED TO STORE
C>   DATA IN THE INTERNAL OUTPUT SUBSET ARRAYS.
C>
C> PROGRAM HISTORY LOG:
C> 1994-01-06  J. WOOLLEN -- ORIGINAL AUTHOR
C> 1998-07-08  J. WOOLLEN -- REPLACED CALL TO CRAY LIBRARY ROUTINE
C>                           "ABORT" WITH CALL TO NEW INTERNAL BUFRLIB
C>                           ROUTINE "BORT"
C> 1999-11-18  J. WOOLLEN -- THE NUMBER OF BUFR FILES WHICH CAN BE
C>                           OPENED AT ONE TIME INCREASED FROM 10 TO 32
C>                           (NECESSARY IN ORDER TO PROCESS MULTIPLE
C>                           BUFR FILES UNDER THE MPI)
C> 2002-05-14  J. WOOLLEN -- REMOVED OLD CRAY COMPILER DIRECTIVES
C> 2003-11-04  S. BENDER  -- ADDED REMARKS/BUFRLIB ROUTINE
C>                           INTERDEPENDENCIES
C> 2003-11-04  D. KEYSER  -- MAXJL (MAXIMUM NUMBER OF JUMP/LINK ENTRIES)
C>                           INCREASED FROM 15000 TO 16000 (WAS IN
C>                           VERIFICATION VERSION); UNIFIED/PORTABLE FOR
C>                           WRF; ADDED DOCUMENTATION (INCLUDING
C>                           HISTORY); OUTPUTS MORE COMPLETE DIAGNOSTIC
C>                           INFO WHEN ROUTINE TERMINATES ABNORMALLY OR
C>                           UNUSUAL THINGS HAPPEN; CHANGED CALL FROM
C>                           BORT TO BORT2 IN SOME CASES
C> 2004-08-18  J. ATOR    -- ADDED SAVE FOR IFIRST1 AND IFIRST2 FLAGS
C> 2009-04-21  J. ATOR    -- USE ERRWRT
C> 2014-12-10  J. ATOR    -- USE MODULES INSTEAD OF COMMON BLOCKS
C> 2015-09-24  D. STOKES  -- FIX MISSING DECLARATION OF COMMON /QUIET/
C>
C> USAGE:    CALL UFBOVR (LUNIT, USR, I1, I2, IRET, STR)
C>   INPUT ARGUMENT LIST:
C>     LUNIT    - INTEGER: FORTRAN LOGICAL UNIT NUMBER FOR BUFR FILE
C>     USR      - REAL*8: (I1,I2) STARTING ADDRESS OF DATA VALUES
C>                WRITTEN TO DATA SUBSET
C>     I1       - INTEGER: LENGTH OF FIRST DIMENSION OF USR (MUST BE AT
C>                LEAST AS LARGE AS THE NUMBER OF BLANK-SEPARATED
C>                MNEMONICS IN STR)
C>     I2       - INTEGER: NUMBER OF "LEVELS" OF DATA VALUES TO BE
C>                WRITTEN TO DATA SUBSET
C>     STR      - CHARACTER*(*): STRING OF BLANK-SEPARATED TABLE B
C>                MNEMONICS IN ONE-TO-ONE CORRESPONDENCE WITH FIRST
C>                DIMENSION OF USR
C>
C>   OUTPUT ARGUMENT LIST:
C>     IRET     - INTEGER: NUMBER OF "LEVELS" OF DATA VALUES WRITTEN TO
C>                DATA SUBSET (SHOULD BE SAME AS I2)
C>
C> REMARKS:
C>    THIS ROUTINE CALLS:        BORT     BORT2    ERRWRT   STATUS
C>                               STRING   TRYBUMP
C>    THIS ROUTINE IS CALLED BY: None
C>                               Normally called only by application
C>                               programs.
C>
      SUBROUTINE UFBOVR(LUNIT,USR,I1,I2,IRET,STR)



      USE MODA_USRINT
      USE MODA_MSGCWD

      INCLUDE 'bufrlib.prm'

      COMMON /QUIET / IPRT

      CHARACTER*128 BORT_STR1,BORT_STR2,ERRSTR
      CHARACTER*(*) STR
      REAL*8        USR(I1,I2)

      DATA IFIRST1/0/,IFIRST2/0/

      SAVE IFIRST1, IFIRST2

C----------------------------------------------------------------------
C----------------------------------------------------------------------

      IRET = 0

C  CHECK THE FILE STATUS AND I-NODE
C  --------------------------------

      CALL STATUS(LUNIT,LUN,IL,IM)
      IF(IL.EQ.0) GOTO 900
      IF(IL.LT.0) GOTO 901
      IF(IM.EQ.0) GOTO 902
      IF(INODE(LUN).NE.INV(1,LUN)) GOTO 903

C  .... DK: Why check, isn't IO always 1 here?
      IO = MIN(MAX(0,IL),1)

      IF(I1.LE.0) THEN
         IF(IPRT.GE.0) THEN
      CALL ERRWRT('+++++++++++++++++++++WARNING+++++++++++++++++++++++')
      ERRSTR = 'BUFRLIB: UFBOVR - 3rd ARG. (INPUT) IS .LE. 0, ' //
     .   'SO RETURN WITH 5th ARG. (IRET) = 0; 6th ARG. (STR) ='
      CALL ERRWRT(ERRSTR)
      CALL ERRWRT(STR)
      CALL ERRWRT('+++++++++++++++++++++WARNING+++++++++++++++++++++++')
      CALL ERRWRT(' ')
         ENDIF
         GOTO 100
      ELSEIF(I2.LE.0) THEN
         IF(IPRT.EQ.-1)  IFIRST1 = 1
         IF(IO.EQ.0 .OR. IFIRST1.EQ.0 .OR. IPRT.GE.1)  THEN
      CALL ERRWRT('+++++++++++++++++++++WARNING+++++++++++++++++++++++')
      ERRSTR = 'BUFRLIB: UFBOVR - 4th ARG. (INPUT) IS .LE. 0, ' //
     .   'SO RETURN WITH 5th ARG. (IRET) = 0; 6th ARG. (STR) ='
      CALL ERRWRT(ERRSTR)
      CALL ERRWRT(STR)
            IF(IPRT.EQ.0 .AND. IO.EQ.1) THEN
      ERRSTR = 'Note: Only the first occurrence of this WARNING ' //
     .   'message is printed, there may be more.  To output all ' //
     .   'such messages,'
      CALL ERRWRT(ERRSTR)
      ERRSTR = 'modify your application program to add ' //
     .   '"CALL OPENBF(0,''QUIET'',1)" prior to the first call ' //
     .   'to a BUFRLIB routine.'
      CALL ERRWRT(ERRSTR)
            ENDIF
      CALL ERRWRT('+++++++++++++++++++++WARNING+++++++++++++++++++++++')
      CALL ERRWRT(' ')
            IFIRST1 = 1
         ENDIF
         GOTO 100
      ENDIF

C  PARSE OR RECALL THE INPUT STRING - READ/WRITE VALUES
C  ----------------------------------------------------

      CALL STRING(STR,LUN,I1,IO)
      CALL TRYBUMP(LUNIT,LUN,USR,I1,I2,IO,IRET)

      IF(IO.EQ.1 .AND. IRET.NE.I2) GOTO 904

      IF(IRET.EQ.0)  THEN
         IF(IPRT.EQ.-1)  IFIRST2 = 1
         IF(IFIRST2.EQ.0 .OR. IPRT.GE.1)  THEN
      CALL ERRWRT('+++++++++++++++++++++WARNING+++++++++++++++++++++++')
      ERRSTR = 'BUFRLIB: UFBOVR - NO SPECIFIED VALUES WRITTEN OUT, ' //
     .   'SO RETURN WITH 5th ARG. (IRET) = 0; 6th ARG. (STR) ='
      CALL ERRWRT(ERRSTR)
      CALL ERRWRT(STR)
      CALL ERRWRT('MAY NOT BE IN THE BUFR TABLE(?)')
               IF(IPRT.EQ.0) THEN
      ERRSTR = 'Note: Only the first occurrence of this WARNING ' //
     .   'message is printed, there may be more.  To output all ' //
     .   'such messages,'
      CALL ERRWRT(ERRSTR)
      ERRSTR = 'modify your application program to add ' //
     .   '"CALL OPENBF(0,''QUIET'',1)" prior to the first call ' //
     .   'to a BUFRLIB routine.'
      CALL ERRWRT(ERRSTR)
               ENDIF
      CALL ERRWRT('+++++++++++++++++++++WARNING+++++++++++++++++++++++')
      CALL ERRWRT(' ')
            IFIRST2 = 1
         ENDIF
      ENDIF

C  EXITS
C  -----

100   RETURN
900   CALL BORT('BUFRLIB: UFBOVR - OUTPUT BUFR FILE IS CLOSED, IT '//
     . 'MUST BE OPEN FOR OUTPUT')
901   CALL BORT('BUFRLIB: UFBOVR - OUTPUT BUFR FILE IS OPEN FOR '//
     . 'INPUT, IT MUST BE OPEN FOR OUTPUT')
902   CALL BORT('BUFRLIB: UFBOVR - A MESSAGE MUST BE OPEN IN OUTPUT '//
     . 'BUFR FILE, NONE ARE')
903   CALL BORT('BUFRLIB: UFBOVR - LOCATION OF INTERNAL TABLE FOR '//
     . 'OUTPUT BUFR FILE DOES NOT AGREE WITH EXPECTED LOCATION IN '//
     . 'INTERNAL SUBSET ARRAY')
904   WRITE(BORT_STR1,'("BUFRLIB: UFBOVR - MNEMONIC STRING READ IN IS'//
     . ': ",A)') STR
      WRITE(BORT_STR2,'(18X,"THE NUMBER OF ''LEVELS'' ACTUALLY '//
     . 'WRITTEN (",I3,") DOES NOT EQUAL THE NUMBER REQUESTED (",I3,")'//
     . ' - INCOMPLETE WRITE")')  IRET,I2
      CALL BORT2(BORT_STR1,BORT_STR2)
      END
