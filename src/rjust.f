C> @file
C> @author WOOLLEN @date 1994-01-06
      
C> THIS FUNCTION RIGHT JUSTIFIES A CHARACTER STRING.
C>
C> PROGRAM HISTORY LOG:
C> 1994-01-06  J. WOOLLEN -- ORIGINAL AUTHOR
C> 2003-11-04  S. BENDER  -- ADDED REMARKS/BUFRLIB ROUTINE
C>                           INTERDEPENDENCIES
C> 2003-11-04  D. KEYSER  -- UNIFIED/PORTABLE FOR WRF; ADDED
C>                           DOCUMENTATION (INCLUDING HISTORY); OUTPUTS
C>                           MORE COMPLETE DIAGNOSTIC INFO WHEN ROUTINE
C>                           TERMINATES ABNORMALLY
C>
C> USAGE:    RJUST (STR)
C>   INPUT ARGUMENT LIST:
C>     STR      - CHARACTER*(*): STRING TO BE RIGHT-JUSTIFED
C>
C>   OUTPUT ARGUMENT LIST:
C>     STR      - CHARACTER*(*): RIGHT-JUSTIFIED STRING
C>     RJUST    - REAL: ALWAYS RETURNED AS 0 (DUMMY)
C>
C> REMARKS:
C>    THIS ROUTINE CALLS:        BORT
C>    THIS ROUTINE IS CALLED BY: SNTBBE   UFBDMP   UFDUMP   VALX
C>                               Normally not called by any application
C>                               programs but it could be.
C>
      FUNCTION RJUST(STR)



      CHARACTER*(*) STR
      RJUST = 0.
      IF(STR.EQ.' ') GOTO 100
      LSTR = LEN(STR)
      DO WHILE(STR(LSTR:LSTR).EQ.' ')
         DO I=LSTR,2,-1
         STR(I:I) = STR(I-1:I-1)
         ENDDO
         STR(1:1) = ' '
      ENDDO

C  EXIT
C  ----

100   RETURN
      END
