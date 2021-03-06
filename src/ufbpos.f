C> @file
C> @author WOOLLEN @date 1995-11-22
      
C> THIS SUBROUTINE SHOULD ONLY BE CALLED WHEN LOGICAL UNIT
C>   LUNIT HAS BEEN OPENED FOR INPUT OPERATIONS.  IT POSITIONS THE
C>   MESSAGE POINTER TO A USER-SPECIFIED BUFR MESSAGE NUMBER IN THE FILE
C>   CONNECTED TO LUNIT AND THEN CALLS BUFR ARCHIVE LIBRARY SUBROUTINE
C>   READMG TO READ THIS BUFR MESSAGE INTO A MESSAGE BUFFER (ARRAY MBAY
C>   IN MODULE BITBUF).  IT THEN POSITIONS THE SUBSET POINTER TO
C>   A USER-SPECIFIED SUBSET NUMBER WITHIN THE BUFR MESSAGE AND CALLS
C>   BUFR ARCHIVE LIBRARY SUBROUTINE READSB TO READ THIS SUBSET INTO
C>   INTERNAL SUBSET ARRAYS.  THE BUFR MESSAGE HERE MAY BE EITHER
C>   COMPRESSED OR UNCOMPRESSED.  THE USER-SPECIFIED MESSAGE NUMBER DOES
C>   NOT INCLUDE ANY DICTIONARY MESSAGES THAT MAY BE AT THE TOP OF THE
C>   FILE).
C>
C> PROGRAM HISTORY LOG:
C> 1995-11-22  J. WOOLLEN -- ORIGINAL AUTHOR (WAS IN-LINED IN PROGRAM
C>                           NAM_STNMLIST)
C> 2005-03-04  D. KEYSER  -- ADDED TO BUFR ARCHIVE LIBRARY; ADDED
C>                           DOCUMENTATION
C> 2005-11-29  J. ATOR    -- USE IUPBS01 AND RDMSGW
C> 2006-04-14  J. ATOR    -- REMOVE UNNECESSARY MOIN INITIALIZATION
C> 2009-03-23  J. ATOR    -- MODIFIED TO HANDLE EMBEDDED BUFR TABLE
C>                           (DICTIONARY) MESSAGES
C> 2014-12-10  J. ATOR    -- USE MODULES INSTEAD OF COMMON BLOCKS
C>
C> USAGE:    CALL UFBPOS( LUNIT, IREC, ISUB, SUBSET, JDATE )
C>   INPUT ARGUMENT LIST:
C>     LUNIT    - INTEGER: FORTRAN LOGICAL UNIT NUMBER FOR BUFR FILE
C>     IREC     - INTEGER: POINTER TO BUFR MESSAGE NUMBER (RECORD) IN
C>                FILE (DOES NOT INCLUDE ANY DICTIONARY MESSSAGES THAT
C>                MAY BE AT THE TOP OF THE FILE)
C>     ISUB     - INTEGER: POINTER TO SUBSET NUMBER TO READ IN BUFR
C>                MESSAGE
C>
C>   OUTPUT ARGUMENT LIST:
C>     SUBSET   - CHARACTER*8: TABLE A MNEMONIC FOR TYPE OF BUFR MESSAGE
C>                BEING READ
C>     JDATE    - INTEGER: DATE-TIME STORED WITHIN SECTION 1 OF BUFR
C>                MESSAGE BEING READ, IN FORMAT OF EITHER YYMMDDHH OR
C>                YYYYMMDDHH, DEPENDING ON DATELEN() VALUE
C>
C> REMARKS:
C>    THIS ROUTINE CALLS:        BORT     CEWIND   NMSUB    READMG
C>                               READSB   STATUS   UFBCNT   UPB
C>    THIS ROUTINE IS CALLED BY: None
C>                               Normally called only by application
C>                               programs.
C>
      SUBROUTINE UFBPOS(LUNIT,IREC,ISUB,SUBSET,JDATE)

      USE MODA_MSGCWD
      USE MODA_BITBUF

      CHARACTER*128 BORT_STR
      CHARACTER*8   SUBSET
 
C-----------------------------------------------------------------------
C----------------------------------------------------------------------

C  MAKE SURE A FILE IS OPEN FOR INPUT
C  ----------------------------------

      CALL STATUS(LUNIT,LUN,IL,IM)
      IF(IL.EQ.0) GOTO 900
      IF(IL.GT.0) GOTO 901

      IF(IREC.LE.0)  GOTO 902
      IF(ISUB.LE.0)  GOTO 903

C  SEE WHERE POINTERS ARE CURRENTLY LOCATED
C  ----------------------------------------

      CALL UFBCNT(LUNIT,JREC,JSUB)
 
C  REWIND FILE IF REQUESTED POINTERS ARE BEHIND CURRENT POINTERS
C  -------------------------------------------------------------
 
      IF(IREC.LT.JREC .OR. (IREC.EQ.JREC.AND.ISUB.LT.JSUB)) THEN
         CALL CEWIND(LUN)
         NMSG(LUN) = 0
         NSUB(LUN) = 0
         CALL UFBCNT(LUNIT,JREC,JSUB)
      ENDIF

C  READ SUBSET #ISUB FROM MESSAGE #IREC FROM FILE
C  ----------------------------------------------

      DO WHILE (IREC.GT.JREC)
         CALL READMG(LUNIT,SUBSET,JDATE,IRET)
         IF(IRET.LT.0) GOTO 904
         CALL UFBCNT(LUNIT,JREC,JSUB)
      ENDDO

      KSUB = NMSUB(LUNIT)
      IF(ISUB.GT.KSUB)  GOTO 905

      DO WHILE (ISUB-1.GT.JSUB)
         IBIT = MBYT(LUN)*8
         CALL UPB(NBYT,16,MBAY(1,LUN),IBIT)
         MBYT(LUN) = MBYT(LUN) + NBYT
         NSUB(LUN) = NSUB(LUN) + 1
         CALL UFBCNT(LUNIT,JREC,JSUB)
      ENDDO

      CALL READSB(LUNIT,IRET)
      IF(IRET.NE.0) GOTO 905

C  EXITS
C  -----

      RETURN
900   CALL BORT('BUFRLIB: UFBPOS - INPUT BUFR FILE IS CLOSED, IT MUST'//
     . ' BE OPEN FOR INPUT')
901   CALL BORT('BUFRLIB: UFBPOS - INPUT BUFR FILE IS OPEN FOR OUTPUT'//
     . ', IT MUST BE OPEN FOR INPUT')
902   WRITE(BORT_STR,'("BUFRLIB: UFBPOS - REQUESTED MESSAGE NUMBER '//
     . 'TO READ IN (",I5,") IS NOT VALID")') IREC
      CALL BORT(BORT_STR)
903   WRITE(BORT_STR,'("BUFRLIB: UFBPOS - REQUESTED SUBSET NUMBER '//
     . 'TO READ IN (",I5,") IS NOT VALID")') ISUB
      CALL BORT(BORT_STR)
904   WRITE(BORT_STR,'("BUFRLIB: UFBPOS - REQUESTED MESSAGE NUMBER '//
     . 'TO READ IN (",I5,") EXCEEDS THE NUMBER OF MESSAGES IN THE '//
     . 'FILE (",I5,")")') IREC,JREC
      CALL BORT(BORT_STR)
905   WRITE(BORT_STR,'("BUFRLIB: UFBPOS - REQ. SUBSET NUMBER TO READ'//
     . ' IN (",I3,") EXCEEDS THE NUMBER OF SUBSETS (",I3,") IN THE '//
     . 'REQ. MESSAGE (",I5,")")') ISUB,KSUB,IREC
      CALL BORT(BORT_STR)
      END
