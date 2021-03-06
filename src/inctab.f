C> @file
C> @author WOOLLEN @date 1994-01-06
      
C> THIS SUBROUTINE RETURNS THE NEXT AVAILABLE POSITIONAL INDEX
C>   FOR WRITING INTO THE INTERNAL JUMP/LINK TABLE IN MODULE TABLES,
C>   AND IT ALSO USES THAT INDEX TO STORE ATAG AND ATYP WITHIN,
C>   RESPECTIVELY, THE INTERNAL JUMP/LINK TABLE ARRAYS TAG(*) AND TYP(*).
C>   IF THERE IS NO MORE ROOM FOR ADDITIONAL ENTRIES WITHIN THE INTERNAL
C>   JUMP/LINK TABLE, THEN AN APPROPRIATE CALL IS MADE TO BUFR ARCHIVE
C>   LIBRARY SUBROUTINE BORT.
C>
C> PROGRAM HISTORY LOG:
C> 1994-01-06  J. WOOLLEN -- ORIGINAL AUTHOR
C> 1998-07-08  J. WOOLLEN -- REPLACED CALL TO CRAY LIBRARY ROUTINE
C>                           "ABORT" WITH CALL TO NEW INTERNAL BUFRLIB
C>                           ROUTINE "BORT"
C> 2003-11-04  J. ATOR    -- ADDED DOCUMENTATION
C> 2003-11-04  S. BENDER  -- ADDED REMARKS/BUFRLIB ROUTINE
C>                           INTERDEPENDENCIES
C> 2003-11-04  D. KEYSER  -- MAXJL (MAXIMUM NUMBER OF JUMP/LINK ENTRIES)
C>                           INCREASED FROM 15000 TO 16000 (WAS IN
C>                           VERIFICATION VERSION); UNIFIED/PORTABLE FOR
C>                           WRF; ADDED HISTORY DOCUMENTATION; OUTPUTS
C>                           MORE COMPLETE DIAGNOSTIC INFO WHEN ROUTINE
C>                           TERMINATES ABNORMALLY
C> 2014-12-10  J. ATOR    -- USE MODULES INSTEAD OF COMMON BLOCKS
C>
C> USAGE:    CALL INCTAB (ATAG, ATYP, NODE)
C>   INPUT ARGUMENT LIST:
C>     ATAG     - CHARACTER*(*): MNEMONIC NAME
C>     ATYP     - CHARACTER*(*): MNEMONIC TYPE
C>
C>   OUTPUT ARGUMENT LIST:
C>     NODE     - INTEGER: NEXT AVAILABLE POSITIONAL INDEX FOR WRITING
C>                INTO THE INTERNAL JUMP/LINK TABLE
C>
C> REMARKS:
C>    THIS ROUTINE CALLS:        BORT
C>    THIS ROUTINE IS CALLED BY: TABENT   TABSUB
C>                               Normally not called by any application
C>                               programs.
C>
      SUBROUTINE INCTAB(ATAG,ATYP,NODE)

      USE MODA_TABLES

      CHARACTER*(*) ATAG,ATYP
      CHARACTER*128 BORT_STR

C-----------------------------------------------------------------------
C-----------------------------------------------------------------------

      NTAB = NTAB+1
      IF(NTAB.GT.MAXTAB) GOTO 900
      TAG(NTAB) = ATAG
      TYP(NTAB) = ATYP
      NODE = NTAB

C  EXITS
C  -----

      RETURN
 900  WRITE(BORT_STR,'("BUFRLIB: INCTAB - THE NUMBER OF JUMP/LINK '//
     . 'TABLE ENTRIES EXCEEDS THE LIMIT, MAXTAB (",I7,")")') MAXTAB
      CALL BORT(BORT_STR)
      END
