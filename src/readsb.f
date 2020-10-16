C> @file
C> @author WOOLLEN @date 1994-01-06
      
C> THIS SUBROUTINE SHOULD ONLY BE CALLED WHEN LOGICAL UNIT
C>   LUNIT HAS BEEN OPENED FOR INPUT OPERATIONS.  IT READS A SUBSET FROM
C>   A BUFR MESSAGE INTO INTERNAL SUBSET ARRAYS.  THE BUFR MESSAGE MUST
C>   HAVE BEEN PREVIOUSLY READ FROM UNIT LUNIT USING BUFR ARCHIVE
C>   LIBRARY SUBROUTINE READMG OR READERME AND MAY BE EITHER COMPRESSED
C>   OR UNCOMPRESSED.
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
C> 2000-09-19  J. WOOLLEN -- ADDED CALL TO NEW ROUTINE RDCMPS ALLOWING
C>                           SUBSETS TO NOW BE DECODED FROM COMPRESSED
C>                           BUFR MESSAGES; MAXIMUM MESSAGE LENGTH
C>                           INCREASED FROM 10,000 TO 20,000 BYTES
C> 2002-05-14  J. WOOLLEN -- CORRECTED ERROR RELATING TO CERTAIN
C>                           FOREIGN FILE TYPES; REMOVED OLD CRAY
C>                           COMPILER DIRECTIVES
C> 2003-11-04  S. BENDER  -- ADDED REMARKS/BUFRLIB ROUTINE
C>                           INTERDEPENDENCIES
C> 2003-11-04  D. KEYSER  -- UNIFIED/PORTABLE FOR WRF; ADDED
C>                           DOCUMENTATION (INCLUDING HISTORY); OUTPUTS
C>                           MORE COMPLETE DIAGNOSTIC INFO WHEN ROUTINE
C>                           TERMINATES ABNORMALLY
C> 2004-08-09  J. ATOR    -- MAXIMUM MESSAGE LENGTH INCREASED FROM
C>                           20,000 TO 50,000 BYTES
C> 2014-12-10  J. ATOR    -- USE MODULES INSTEAD OF COMMON BLOCKS
C>
C> USAGE:    CALL READSB (LUNIT, IRET)
C>   INPUT ARGUMENT LIST:
C>     LUNIT    - INTEGER: FORTRAN LOGICAL UNIT NUMBER FOR BUFR FILE
C>
C>   OUTPUT ARGUMENT LIST:
C>     IRET     - INTEGER: RETURN CODE:
C>                       0 = normal return
C>                      -1 = there are no more subsets in the BUFR
C>                           message
C>
C> REMARKS:
C>    THIS ROUTINE CALLS:        BORT     RDCMPS   RDTREE   STATUS
C>                               UPB
C>    THIS ROUTINE IS CALLED BY: COPYSB   IREADSB  RDMEMS   READNS
C>                               RDMSGB   UFBINX   UFBPOS
C>                               Also called by application programs.
C>
      SUBROUTINE READSB(LUNIT,IRET)



      USE MODA_MSGCWD
      USE MODA_UNPTYP
      USE MODA_BITBUF
      USE MODA_BITMAPS

      INCLUDE 'bufrlib.prm'

      CHARACTER*128 BORT_STR

C-----------------------------------------------------------------------
C-----------------------------------------------------------------------

      IRET = 0

C  CHECK THE FILE STATUS
C  ---------------------

      CALL STATUS(LUNIT,LUN,IL,IM)
      IF(IL.EQ.0) GOTO 900
      IF(IL.GT.0) GOTO 901
      IF(IM.EQ.0) THEN
         IRET = -1
         GOTO 100
      ENDIF

C  SEE IF THERE IS ANOTHER SUBSET IN THE MESSAGE
C  ---------------------------------------------

      IF(NSUB(LUN).EQ.MSUB(LUN)) THEN
         IRET = -1
         GOTO 100
      ELSE
         NSUB(LUN) = NSUB(LUN) + 1
      ENDIF

C  READ THE NEXT SUBSET AND RESET THE POINTERS
C  -------------------------------------------

      NBTM = 0
      LSTNOD = 0
      LSTNODCT = 0
      LINBTM = .FALSE.

      IF(MSGUNP(LUN).EQ.0) THEN
         IBIT = MBYT(LUN)*8
         CALL UPB(NBYT,16,MBAY(1,LUN),IBIT)
         CALL RDTREE(LUN,IER)
         IF(IER.NE.0) THEN
           IRET = -1
           GOTO 100
         ENDIF
         MBYT(LUN) = MBYT(LUN) + NBYT
      ELSEIF(MSGUNP(LUN).EQ.1) THEN
c  .... message with "standard" Section 3
         IBIT = MBYT(LUN)
         CALL RDTREE(LUN,IER)
         IF(IER.NE.0) THEN
           IRET = -1
           GOTO 100
         ENDIF
         MBYT(LUN) = IBIT
      ELSEIF(MSGUNP(LUN).EQ.2) THEN
c  .... compressed message
         CALL RDCMPS(LUN)
      ELSE
         GOTO 902
      ENDIF

C  EXITS
C  -----

100   RETURN
900   CALL BORT('BUFRLIB: READSB - INPUT BUFR FILE IS CLOSED, IT MUST'//
     . ' BE OPEN FOR INPUT')
901   CALL BORT('BUFRLIB: READSB - INPUT BUFR FILE IS OPEN FOR OUTPUT'//
     . ', IT MUST BE OPEN FOR INPUT')
902   WRITE(BORT_STR,'("BUFRLIB: READSB - MESSAGE UNPACK TYPE",I3,"IS'//
     . ' NOT RECOGNIZED")') MSGUNP
      CALL BORT(BORT_STR)
      END
