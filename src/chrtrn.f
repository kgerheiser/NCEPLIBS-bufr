C> @file
C> @author WOOLLEN @date 1994-01-06
      
C> THIS SUBROUTINE COPIES A SPECIFIED NUMBER OF CHARACTERS
C>   FROM A CHARACTER ARRAY INTO A CHARACTER STRING.
C>
C> PROGRAM HISTORY LOG:
C> 1994-01-06  J. WOOLLEN -- ORIGINAL AUTHOR
C> 2003-11-04  J. ATOR    -- ADDED DOCUMENTATION
C> 2003-11-04  S. BENDER  -- ADDED REMARKS/BUFRLIB ROUTINE
C>                           INTERDEPENDENCIES
C> 2003-11-04  D. KEYSER  -- UNIFIED/PORTABLE FOR WRF; ADDED HISTORY
C>                           DOCUMENTATION
C>
C> USAGE:    CALL CHRTRN (STR, CHR, N)
C>   INPUT ARGUMENT LIST:
C>     CHR      - CHARACTER*1: N-WORD CHARACTER ARRAY
C>     N        - INTEGER: NUMBER OF CHARACTERS TO COPY
C>
C>   OUTPUT ARGUMENT LIST:
C>     STR      - CHARACTER*(*): CHARACTER STRING
C>
C> REMARKS:
C>    THIS ROUTINE CALLS:        None
C>    THIS ROUTINE IS CALLED BY: None
C>                               Normally not called by any application
C>                               programs but it could be.
C>
      SUBROUTINE CHRTRN(STR,CHR,N)



      CHARACTER*(*) STR
      CHARACTER*1   CHR(N)

C----------------------------------------------------------------------
C----------------------------------------------------------------------
      DO I=1,N
      STR(I:I) = CHR(I)
      ENDDO
      RETURN
      END
