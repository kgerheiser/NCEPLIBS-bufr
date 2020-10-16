C> @file
C> @author WOOLLEN @date 2003-11-04
      
C> THIS SUBROUTINE OPENS A BUFR FILE IN LOGICAL UNIT LUNIT FOR
C>   INPUT OPERATIONS, THEN READS A PARTICULAR SUBSET INTO INTERNAL
C>   SUBSET ARRAYS FROM A PARTICULAR BUFR MESSAGE IN A MESSAGE BUFFER.
C>   THIS IS BASED ON THE SUBSET NUMBER IN THE MESSAGE AND THE MESSAGE
C>   NUMBER IN THE BUFR FILE.  THE MESSAGE NUMBER DOES NOT INCLUDE THE
C>   DICTIONARY MESSAGES AT THE BEGINNING OF THE FILE.
C>
C> PROGRAM HISTORY LOG:
C> 2003-11-04  J. WOOLLEN -- ORIGINAL AUTHOR (WAS IN VERIFICATION
C>                           VERSION BUT MAY HAVE BEEN IN THE PRODUCTION
C>                           VERSION AT ONE TIME AND THEN REMOVED)
C> 2003-11-04  D. KEYSER  -- INCORPORATED INTO "UNIFIED" BUFR ARCHIVE
C>                           LIBRARY; UNIFIED/PORTABLE FOR WRF; ADDED
C>                           DOCUMENTATION; OUTPUTS MORE COMPLETE
C>                           DIAGNOSTIC INFO WHEN ROUTINE TERMINATES
C>                           ABNORMALLY
C> 2004-08-09  J. ATOR    -- MAXIMUM MESSAGE LENGTH INCREASED FROM
C>                           20,000 TO 50,000 BYTES
C> 2009-03-23  J. ATOR    -- MODIFY LOGIC TO HANDLE BUFR TABLE MESSAGES
C>                           ENCOUNTERED ANYWHERE IN THE FILE (AND NOT
C>                           JUST AT THE BEGINNING!)
C> 2014-12-10  J. ATOR    -- USE MODULES INSTEAD OF COMMON BLOCKS
C>
C> USAGE:    CALL RDMGSB (LUNIT, IMSG, ISUB)
C>   INPUT ARGUMENT LIST:
C>     LUNIT    - INTEGER: FORTRAN LOGICAL UNIT NUMBER FOR BUFR FILE
C>     IMSG     - INTEGER: POINTER TO BUFR MESSAGE NUMBER TO READ IN
C>                BUFR FILE
C>     ISUB     - INTEGER: POINTER TO SUBSET NUMBER TO READ IN BUFR
C>                MESSAGE
C>
C>   INPUT FILES:
C>     UNIT "LUNIT" - BUFR FILE
C>
C> REMARKS:
C>    THIS ROUTINE CALLS:        BORT     OPENBF   READMG   READSB
C>                               STATUS   UPB
C>    THIS ROUTINE IS CALLED BY: None
C>                               Normally called only by application
C>                               programs.
C>
      SUBROUTINE RDMGSB(LUNIT,IMSG,ISUB)



      USE MODA_MSGCWD
      USE MODA_BITBUF

      INCLUDE 'bufrlib.prm'

      CHARACTER*128 BORT_STR
      CHARACTER*8   SUBSET

C-----------------------------------------------------------------------
C-----------------------------------------------------------------------

C  OPEN THE FILE AND SKIP TO MESSAGE # IMSG
C  ----------------------------------------

      CALL OPENBF(LUNIT,'IN',LUNIT)
      CALL STATUS(LUNIT,LUN,IL,IM)

C     Note that we need to use subroutine READMG to actually read in all
C     of the messages (including the first (IMSG-1) messages!), just in
C     case there are any embedded dictionary messages in the file.

      DO I=1,IMSG
        CALL READMG(LUNIT,SUBSET,JDATE,IRET)
        IF(IRET.LT.0) GOTO 901
      ENDDO

C  POSITION AT SUBSET # ISUB
C  -------------------------

      DO I=1,ISUB-1
        IF(NSUB(LUN).GT.MSUB(LUN)) GOTO 902
        IBIT = MBYT(LUN)*8
        CALL UPB(NBYT,16,MBAY(1,LUN),IBIT)
        MBYT(LUN) = MBYT(LUN) + NBYT
        NSUB(LUN) = NSUB(LUN) + 1
      ENDDO

      CALL READSB(LUNIT,IRET)
      IF(IRET.NE.0) GOTO 902

C  EXITS
C  -----

      RETURN
900   WRITE(BORT_STR,'("BUFRLIB: RDMGSB - ERROR READING MESSAGE '//
     . '(RECORD) NUMBER",I5," IN INPUT BUFR FILE CONNECTED TO UNIT",'//
     . 'I4)')  I,LUNIT
      CALL BORT(BORT_STR)
901   WRITE(BORT_STR,'("BUFRLIB: RDMGSB - HIT END OF FILE BEFORE '//
     . 'READING REQUESTED MESSAGE NO.",I5," IN BUFR FILE CONNECTED TO'//
     . ' UNIT",I4)')  IMSG,LUNIT
      CALL BORT(BORT_STR)
902   WRITE(BORT_STR,'("BUFRLIB: RDMGSB - ALL SUBSETS READ BEFORE '//
     . 'READING REQ. SUBSET NO.",I3," IN REQ. MSG NO.",I5," IN BUFR '//
     . 'FILE CONNECTED TO UNIT",I4)') ISUB,IMSG,LUNIT
      CALL BORT(BORT_STR)
      END
