C> @file
C> @author ATOR @date 2009-03-23
      
C> THIS FUNCTION UNPACKS AND RETURNS A SPECIFIED INTEGER VALUE
C>   FROM SECTION 3 OF THE BUFR MESSAGE STORED IN ARRAY MBAY.  IT WILL
C>   WORK ON ANY MESSAGE ENCODED USING BUFR EDITION 2, 3 OR 4.  THE START
C>   OF THE BUFR MESSAGE (I.E. THE STRING "BUFR") MUST BE ALIGNED ON THE
C>   FIRST FOUR BYTES OF MBAY, AND THE VALUE TO BE UNPACKED IS SPECIFIED
C>   VIA THE MNEMONIC S3MNEM, AS EXPLAINED IN FURTHER DETAIL BELOW.
C>
C> PROGRAM HISTORY LOG:
C> 2009-03-23  J. ATOR    -- ORIGINAL AUTHOR
C>
C> USAGE:    IUPBS3 (MBAY, S3MNEM)
C>   INPUT ARGUMENT LIST:
C>     MBAY     - INTEGER: *-WORD PACKED BINARY ARRAY CONTAINING
C>                BUFR MESSAGE
C>     S3MNEM   - CHARACTER*(*): MNEMONIC SPECIFYING VALUE TO BE
C>                UNPACKED FROM SECTION 3 OF BUFR MESSAGE:
C>                  'NSUB'  = NUMBER OF DATA SUBSETS
C>                  'IOBS'  = FLAG INDICATING WHETHER THE MESSAGE
C>                            CONTAINS OBSERVED DATA:
C>                              0 = NO
C>                              1 = YES
C>                  'ICMP'  = FLAG INDICATING WHETHER THE MESSAGE
C>                            CONTAINS COMPRESSED DATA:
C>                              0 = NO
C>                              1 = YES
C>
C>   OUTPUT ARGUMENT LIST:
C>     IUPBS3   - INTEGER: UNPACKED INTEGER VALUE
C>                  -1 = THE INPUT S3MNEM MNEMONIC WAS INVALID
C>
C> REMARKS:
C>    THIS ROUTINE CALLS:        GETLENS  IUPB
C>    THIS ROUTINE IS CALLED BY: CKTABA   CPDXMM   DUMPBF   MESGBC
C>                               RDBFDX   READERME STNDRD   WRITLC
C>                               Also called by application programs.
C>
      FUNCTION IUPBS3(MBAY,S3MNEM)



	DIMENSION	MBAY(*)

	CHARACTER*(*)	S3MNEM

C-----------------------------------------------------------------------
C-----------------------------------------------------------------------

C	Call subroutine WRDLEN to initialize some important information
C	about the local machine, just in case subroutine OPENBF hasn't
C	been called yet.

	CALL WRDLEN

C	Skip to the beginning of Section 3.

	CALL GETLENS(MBAY,3,LEN0,LEN1,LEN2,LEN3,L4,L5)
	IPT = LEN0 + LEN1 + LEN2

C	Unpack the requested value.

	IF(S3MNEM.EQ.'NSUB') THEN
	    IUPBS3 = IUPB(MBAY,IPT+5,16)
	ELSE IF( (S3MNEM.EQ.'IOBS') .OR. (S3MNEM.EQ.'ICMP') ) THEN
	    IVAL = IUPB(MBAY,IPT+7,8)
	    IF(S3MNEM.EQ.'IOBS') THEN
		IMASK = 128
	    ELSE
		IMASK = 64
	    ENDIF
	    IUPBS3 = MIN(1,IAND(IVAL,IMASK))
	ELSE
	    IUPBS3 = -1
	ENDIF

	RETURN
	END
