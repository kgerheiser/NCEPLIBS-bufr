C> @file
C> @author KEYSER @date 2003-11-04
      
C> THIS SUBROUTINE WRITES (VIA BUFR ARCHIVE LIBRARY SUBROUTINE
C>   ERRWRT) TWO GIVEN ERROR STRINGS AND THEN CALLS BUFR ARCHIVE LIBRARY
C>   SUBROUTINE BORT_EXIT TO ABORT THE APPLICATION PROGRAM CALLING THE
C>   BUFR ARCHIVE LIBRARY SOFTWARE. IT IS SIMILAR TO BUFR ARCHIVE LIBRARY
C>   SUBROUTINE BORT, EXCEPT BORT PRINTS ONLY ONE ERROR STRING.
C>
C> PROGRAM HISTORY LOG:
C> 2003-11-04  D. KEYSER  -- ORIGINAL AUTHOR
C> 2009-04-21  J. ATOR    -- USE ERRWRT
C>
C> USAGE:    CALL BORT2 (STR1, STR2)
C>   INPUT ARGUMENT LIST:
C>     STR1     - CHARACTER*(*): FIRST ERROR MESSAGE TO BE WRITTEN VIA
C>                SUBROUTINE ERRWRT
C>     STR2     - CHARACTER*(*): SECOND ERROR MESSAGE TO BE WRITTEN VIA
C>                SUBROUTINE ERRWRT
C>
C> REMARKS:
C>    THIS ROUTINE CALLS:        BORT_EXIT ERRWRT
C>    THIS ROUTINE IS CALLED BY: ELEMDX   GETNTBE  IREADMT  MTFNAM
C>                               MTINFO   PARSTR   PARUSR   PARUTG
C>                               RDUSDX   SEQSDX   SNTBBE   SNTBDE
C>                               SNTBFE   STRING   UFBINT   UFBOVR
C>                               UFBREP   UFBSTP   VALX
C>                               Normally not called by any application
C>                               programs but it could be.
C>
      SUBROUTINE BORT2(STR1,STR2)



      CHARACTER*(*) STR1, STR2

      CALL ERRWRT(' ')
      CALL ERRWRT('***********BUFR ARCHIVE LIBRARY ABORT**************')
      CALL ERRWRT(STR1)
      CALL ERRWRT(STR2)
      CALL ERRWRT('***********BUFR ARCHIVE LIBRARY ABORT**************')
      CALL ERRWRT(' ')

      CALL BORT_EXIT

      END
