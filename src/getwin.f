C> @file
C> @author WOOLLEN @date 1994-01-06
      
C> GIVEN A NODE INDEX WITHIN THE INTERNAL JUMP/LINK TABLE, THIS
C>   SUBROUTINE LOOKS WITHIN THE CURRENT SUBSET BUFFER FOR A "WINDOW"
C>   (SEE BELOW REMARKS) WHICH CONTAINS THIS NODE.  IF FOUND, IT RETURNS
C>   THE STARTING AND ENDING INDICES OF THIS WINDOW WITHIN THE CURRENT
C>   SUBSET BUFFER.  FOR EXAMPLE, IF THE NODE IS FOUND WITHIN THE SUBSET
C>   BUT IS NOT PART OF A DELAYED REPLICATION SEQUENCE, THEN THE RETURNED
C>   INDICES DEFINE THE START AND END OF THE ENTIRE SUBSET BUFFER.
C>   OTHERWISE, THE RETURNED INDICES DEFINE THE START AND END OF THE NEXT
C>   AVAILABLE DELAYED REPLICATION SEQUENCE ITERATION WHICH CONTAINS THE
C>   NODE.  IF NO FURTHER ITERATIONS OF THE SEQUENCE CAN BE FOUND, THEN
C>   THE STARTING INDEX IS RETURNED WITH A VALUE OF ZERO.
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
C>                           HISTORY) (INCOMPLETE); OUTPUTS MORE
C>                           COMPLETE DIAGNOSTIC INFO WHEN ROUTINE
C>                           TERMINATES ABNORMALLY
C> 2009-03-31  J. WOOLLEN -- ADDED ADDITIONAL DOCUMENTATION
C> 2009-05-07  J. ATOR    -- USE LSTJPB INSTEAD OF LSTRPC
C> 2014-12-10  J. ATOR    -- USE MODULES INSTEAD OF COMMON BLOCKS
C>
C> USAGE:    CALL GETWIN (NODE, LUN, IWIN, JWIN)
C>   INPUT ARGUMENT LIST:
C>     NODE     - INTEGER: JUMP/LINK TABLE INDEX OF MNEMONIC TO LOOK FOR
C>     LUN      - INTEGER: I/O STREAM INDEX INTO INTERNAL MEMORY ARRAYS
C>     JWIN     - INTEGER: ENDING INDEX OF THE PREVIOUS WINDOW ITERATION
C>                WHICH CONTAINED NODE
C>
C>   OUTPUT ARGUMENT LIST:
C>     IWIN     - INTEGER: STARTING INDEX OF THE CURRENT WINDOW ITERATION
C>                WHICH CONTAINS NODE 
C>                  0 = NOT FOUND OR NO MORE ITERATIONS AVAILABLE
C>     JWIN     - INTEGER: ENDING INDEX OF THE CURRENT WINDOW ITERATION
C>                WHICH CONTAINS NODE 
C>
C> REMARKS:
C>
C>    THIS IS ONE OF A NUMBER OF SUBROUTINES WHICH OPERATE ON "WINDOWS"
C>    (I.E. CONTIGUOUS PORTIONS) OF THE INTERNAL SUBSET BUFFER.  THE
C>    SUBSET BUFFER IS AN ARRAY OF VALUES ARRANGED ACCORDING TO THE
C>    OVERALL TEMPLATE DEFINITION FOR A SUBSET.  A WINDOW CAN BE ANY
C>    CONTIGUOUS PORTION OF THE SUBSET BUFFER UP TO AND INCLUDING THE
C>    ENTIRE SUBSET BUFFER ITSELF.  FOR THE PURPOSES OF THESE "WINDOW
C>    OPERATOR" SUBROUTINES, A WINDOW ESSENTIALLY CONSISTS OF ALL OF THE
C>    ELEMENTS WITHIN A PARTICULAR DELAYED REPLICATION GROUP, SINCE SUCH
C>    GROUPS EFFECTIVELY DEFINE THE DIMENSIONS WITHIN A BUFR SUBSET FOR
C>    THE BUFR ARCHIVE LIBRARY SUBROUTINES SUCH AS UFBINT, UFBIN3, ETC.
C>    WHICH READ/WRITE INDIVIDUAL DATA VALUES.  A BUFR SUBSET WITH NO
C>    DELAYED REPLICATION GROUPS IS CONSIDERED TO HAVE ONLY ONE
C>    DIMENSION, AND THEREFORE ONLY ONE "WINDOW" WHICH SPANS THE ENTIRE
C>    SUBSET.  ON THE OTHER HAND, EACH DELAYED REPLICATION SEQUENCE
C>    WITHIN A BUFR SUBSET CONSISTS OF SOME NUMBER OF "WINDOWS", WHICH
C>    ARE A DE-FACTO SECOND DIMENSION OF THE SUBSET AND WHERE THE NUMBER
C>    OF WINDOWS IS THE DELAYED DESCRIPTOR REPLICATION FACTOR (I.E. THE
C>    NUMBER OF ITERATIONS) OF THE SEQUENCE.  IF NESTED DELAYED
C>    REPLICATION IS USED, THEN THERE MAY BE THREE OR MORE DIMENSIONS
C>    WITHIN THE SUBSET.
C>
C>    THIS ROUTINE CALLS:        BORT     INVWIN   LSTJPB
C>    THIS ROUTINE IS CALLED BY: CONWIN   UFBEVN   UFBIN3   UFBRW
C>                               Normally not called by any application
C>                               programs.
C>
      SUBROUTINE GETWIN(NODE,LUN,IWIN,JWIN)



      USE MODA_USRINT

      INCLUDE 'bufrlib.prm'

      CHARACTER*128 BORT_STR

C----------------------------------------------------------------------
C----------------------------------------------------------------------

      IRPC = LSTJPB(NODE,LUN,'RPC')

      IF(IRPC.EQ.0) THEN
         IWIN = INVWIN(NODE,LUN,JWIN,NVAL(LUN))
         IF(IWIN.EQ.0 .and. JWIN.GT.1) GOTO 100
         IWIN = 1
         JWIN = NVAL(LUN)
         GOTO 100
      ELSE
         IWIN = INVWIN(IRPC,LUN,JWIN,NVAL(LUN))
         IF(IWIN.EQ.0) THEN
            GOTO 100
         ELSEIF(VAL(IWIN,LUN).EQ.0.) THEN
            IWIN = 0
            GOTO 100
         ENDIF
      ENDIF

      JWIN = INVWIN(IRPC,LUN,IWIN+1,NVAL(LUN))
      IF(JWIN.EQ.0) GOTO 900

C  EXITS
C  -----

100   RETURN
900   WRITE(BORT_STR,'("BUFRLIB: GETWIN - SEARCHED BETWEEN",I5," AND"'//
     . ',I5,", MISSING BRACKET")') IWIN+1,NVAL(LUN)
      CALL BORT(BORT_STR)
      END
