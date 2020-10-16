C> @file
C> @author WOOLLEN @date 1994-01-06
      
C> THIS LOGICAL FUNCTION TESTS THE CHARACTERS IN A STRING TO
C>   DETERMINE IF THEY ARE ALL DIGITS ('0','1','2','3','4','5','6','7',
C>   '8' OR '9').
C>
C> PROGRAM HISTORY LOG:
C> 1994-01-06  J. WOOLLEN -- ORIGINAL AUTHOR
C> 2003-11-04  S. BENDER  -- ADDED REMARKS/BUFRLIB ROUTINE
C>                           INTERDEPENDENCIES
C> 2003-11-04  D. KEYSER  -- UNIFIED/PORTABLE FOR WRF; ADDED
C>                           DOCUMENTATION (INCLUDING HISTORY)
C> 2007-01-19  J. ATOR    -- SIMPLIFIED LOGIC
C> 2009-03-23  J. ATOR    -- FIXED MINOR BUG CAUSED BY TYPO
C>
C> USAGE:    DIGIT (STR)
C>   INPUT ARGUMENT LIST:
C>     STR      - CHARACTER*(*): STRING
C>
C>   OUTPUT ARGUMENT LIST:
C>     DIGIT    - LOGICAL: TRUE IF ALL CHARACTERS IN STR ARE DIGITS
C>                ('0' - '9'), OTHERWISE FALSE
C>
C> REMARKS:
C>    THIS ROUTINE CALLS:        None
C>    THIS ROUTINE IS CALLED BY: CKTABA   NUMBCK   STNTBIA
C>                               Normally not called by any application
C>                               programs but it could be.
C>
      LOGICAL FUNCTION DIGIT(STR)



      CHARACTER*(*) STR
      DIGIT = .FALSE.
      DO I=1,LEN(STR)
        IF( LLT(STR(I:I),'0') .OR. LGT(STR(I:I),'9') ) GOTO 100
      ENDDO
      DIGIT = .TRUE.

C  EXIT
C  ----

100   RETURN
      END
