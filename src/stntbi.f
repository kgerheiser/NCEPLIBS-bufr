C> @file
C> @author ATOR @date 2009-03-23
	
C> THIS SUBROUTINE STORES A NEW ENTRY WITHIN INTERNAL BUFR
C>   TABLE B OR D, DEPENDING ON THE VALUE OF NUMB.
C>
C> PROGRAM HISTORY LOG:
C> 2009-03-23  J. ATOR    -- ORIGINAL AUTHOR
C> 2014-12-10  J. ATOR    -- USE MODULES INSTEAD OF COMMON BLOCKS
C>
C> USAGE:    CALL STNTBI ( N, LUN, NUMB, NEMO, CELSQ )
C>   INPUT ARGUMENT LIST:
C>       N      - INTEGER: STORAGE INDEX INTO INTERNAL TABLE B OR D 
C>     LUN      - INTEGER: I/O STREAM INDEX INTO INTERNAL TABLE B OR D
C>    NUMB      - CHARACTER*6: FXY NUMBER FOR NEW TABLE B OR D ENTRY
C>                (IN FORMAT FXXYYY)
C>    NEMO      - CHARACTER*8: MNEMONIC CORRESPONDING TO NUMB
C>   CELSQ      - CHARACTER*55: ELEMENT OR SEQUENCE DESCRIPTION
C>                CORRESPONDING TO NUMB
C>
C> REMARKS:
C>    THIS ROUTINE CALLS:        IFXY     NENUBD
C>    THIS ROUTINE IS CALLED BY: RDUSDX   STSEQ
C>                               Not normally called by application
C>                               programs.
C>
	SUBROUTINE STNTBI ( N, LUN, NUMB, NEMO, CELSQ )



	USE MODA_TABABD

	INCLUDE 'bufrlib.prm'

	CHARACTER*(*) NUMB, NEMO, CELSQ

C-----------------------------------------------------------------------
C-----------------------------------------------------------------------

	CALL NENUBD ( NEMO, NUMB, LUN )

	IF ( NUMB(1:1) .EQ. '0') THEN
            IDNB(N,LUN) = IFXY(NUMB)
            TABB(N,LUN)( 1: 6) = NUMB(1:6)
            TABB(N,LUN)( 7:14) = NEMO(1:8)
            TABB(N,LUN)(16:70) = CELSQ(1:55)
            NTBB(LUN) = N
	ELSE IF ( NUMB(1:1) .EQ. '3') THEN
            IDND(N,LUN) = IFXY(NUMB)
            TABD(N,LUN)( 1: 6) = NUMB(1:6)
            TABD(N,LUN)( 7:14) = NEMO(1:8)
            TABD(N,LUN)(16:70) = CELSQ(1:55)
            NTBD(LUN) = N
        ENDIF

	RETURN
	END
