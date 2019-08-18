     H DFTACTGRP(*NO) Debug(*YES) Option(*SrcStmt: *NoDebugIO)
      *
      * Subpar SHA-256 implementation
      * Barrett Otte 2019
      * https://github.com/barrettotte/RPGLE-BTC-Hash
      *
      * Since this will be used for the BTC hash algorithm,
      *     I decided to make most of this fixed length.
      *
      * Questions to ask:
      *  - Main, subprocs, and prototypes
      *  - uint(10) -> uint(20) ?
      *  - Error handling


      /free

       Dcl-Pr Main ExtPgm('SHA256');
         // ??
       End-Pr;

       Dcl-Pi Main;
         // uhh yeah im not sure what to do here ?
       End-Pi;


      * Prototypes
      *
       // Convert uint32 from little to big endian
       Dcl-Pr EndianL2B Uns(10);
         val            Uns(10);
       End-Pr;

       Dcl-Pr ShiftRight Uns(20);
         val             Uns(20);
         shift           Uns(20);
       End-Pr;

       Dcl-Pr ShiftLeft Uns(20);
         val            Uns(20);
         shift          Uns(20);
       End-Pr;


      * Params
       Dcl-S msg Uns(3) Dim(1024);
       Dcl-S msgBytes Uns(5);


      * Variables
       Dcl-S k Uns(10) Dim(64);         // round constants
       Dcl-S hash Uns(10) Dim(8);       // hash to return
       Dcl-S buffer Uns(3) Dim(1024);   // message buffer
       Dcl-S msgBits Uns(5);            // message size in bits
       Dcl-S numBlocks Uns(3) Inz(17);  // blocks needed to hash msg
       Dcl-S paddedMsg Uns(10) Dim(272);// 16*2

       Dcl-S i Uns(10);                 // iterator
       Dcl-S tNum Uns(5);               // used in dbg loops


      // TODO: Move this to subroutine
      *Init hash -> first 32-bits of fractional parts of
      *    square roots of first 8 primes [2..19]
       hash(1) = X'6a09e667';
       hash(2) = X'bb67ae85';
       hash(3) = X'3c6ef372';
       hash(4) = X'a54ff53a';
       hash(5) = X'510e527f';
       hash(6) = X'9b05688c';
       hash(7) = X'1f83d9ab';
       hash(8) = X'5be0cd19';


      // TODO: Move this to subroutine
      * Init round constants -> first 32-bits of fractional parts
      *    of the cube roots of the first 64 primes [2..311]
      * Might be a good idea to use a table, but maybe this is "faster"?

       k(1)  = X'428a2f98';
       k(2)  = X'71374491';
       k(3)  = X'b5c0fbcf';
       k(4)  = X'e9b5dba5';
       k(5)  = X'3956c25b';
       k(6)  = X'59f111f1';
       k(7)  = X'923f82a4';
       k(8)  = X'ab1c5ed5';
       k(9)  = X'd807aa98';
       k(10) = X'12835b01';
       k(11) = X'243185be';
       k(12) = X'550c7dc3';
       k(13) = X'72be5d74';
       k(14) = X'80deb1fe';
       k(15) = X'9bdc06a7';
       k(16) = X'c19bf174';
       k(17) = X'e49b69c1';
       k(18) = X'efbe4786';
       k(19) = X'0fc19dc6';
       k(20) = X'240ca1cc';
       k(21) = X'2de92c6f';
       k(22) = X'4a7484aa';
       k(23) = X'5cb0a9dc';
       k(24) = X'76f988da';
       k(25) = X'983e5152';
       k(26) = X'a831c66d';
       k(27) = X'b00327c8';
       k(28) = X'bf597fc7';
       k(29) = X'c6e00bf3';
       k(30) = X'd5a79147';
       k(31) = X'06ca6351';
       k(32) = X'14292967';
       k(33) = X'27b70a85';
       k(34) = X'2e1b2138';
       k(35) = X'4d2c6dfc';
       k(36) = X'53380d13';
       k(37) = X'650a7354';
       k(38) = X'766a0abb';
       k(39) = X'81c2c92e';
       k(40) = X'92722c85';
       k(41) = X'a2bfe8a1';
       k(42) = X'a81a664b';
       k(43) = X'c24b8b70';
       k(44) = X'c76c51a3';
       k(45) = X'd192e819';
       k(46) = X'd6990624';
       k(47) = X'f40e3585';
       k(48) = X'106aa070';
       k(49) = X'19a4c116';
       k(50) = X'1e376c08';
       k(51) = X'2748774c';
       k(52) = X'34b0bcb5';
       k(53) = X'391c0cb3';
       k(54) = X'4ed8aa4a';
       k(55) = X'5b9cca4f';
       k(56) = X'682e6ff3';
       k(57) = X'748f82ee';
       k(58) = X'78a5636f';
       k(59) = X'84c87814';
       k(60) = X'8cc70208';
       k(61) = X'90befffa';
       k(62) = X'a4506ceb';
       k(63) = X'bef9a3f7';
       k(64) = X'c67178f2';


      * TESTING...Pretend this was passed to the program
       msgBytes = 3;
       msg(1) = X'81';
       msg(2) = X'cd';
       msg(3) = X'02';
      * hash:
      * 4189c360b244d82b862073dc4c2e5a23e40bc86aa118ed854e755b335e126983


      * Pre-Processing
       msgBits = msgBytes * 8;
       numBlocks = 1 + ((msgBits + 80) / 512);
      *Dsply ('msgBits = ' + %Char(msgBits));
      *Dsply ('msgBytes = ' + %Char(msgBytes));
      *Dsply ('numBlocks = ' + %Char(numBlocks));

       For i = 1 To msgBytes;
         paddedMsg(i) = msg(i);
       EndFor;
       paddedMsg(msgBytes + 1) = X'80'; //append 1 in big endian

      * Convert from little to big endian
       For i = 1 To (NumBlocks * 16);
         paddedMsg(i) = EndianL2B(paddedMsg(i));
       EndFor;





       *INLR = *ON;



      * +---------------------------------------------------------+
      * |                        Procedures                       |
      * +---------------------------------------------------------+

       Dcl-Proc ShiftLeft;
         Dcl-Pi *N Uns(20);
           val     Uns(20);
           shift   Uns(20);
         End-Pi;
         return val * %UnsH(2 ** shift);
       End-Proc;

       Dcl-Proc ShiftRight;
         Dcl-Pi *N Uns(20);
           val     Uns(20);
           shift   Uns(20);
         End-Pi;
         return %Div(val : %UnsH(2 ** shift));
       End-Proc;


       Dcl-Proc EndianL2B;
         Dcl-Pi *N Uns(10);
           val     Uns(10);
         End-Pi;

         Dcl-S swapped Uns(10);
         //swapped = %BitAnd(ShiftLeft(val:8) : x'ff00ff00');
         swapped = ShiftLeft(val: 8);
         return swapped;
       End-Proc;


