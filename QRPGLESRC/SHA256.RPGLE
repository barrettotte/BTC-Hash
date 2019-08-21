     H DFTACTGRP(*NO) Debug(*YES) Option(*SrcStmt: *NoDebugIO)
      /free
       // Ctl-Opt DftActGrp(*No) Debug(*Yes) Option(*SrcStmt: *NoDebugIO)
       // Subpar SHA-256 implementation
       // Barrett Otte 2019
       // https://github.com/barrettotte/RPGLE-BTC-Hash

       // Since this will be used for the BTC hash algorithm,
       //   I decided to make most of this fixed length.


       Dcl-Pr Main EXTPGM('SHA256');
        // msg      Uns(3) Dim(1024);
        // msgBytes Uns(5);
       End-Pr;

       Dcl-Pi Main;
        // msg      Uns(3) Dim(1024);
        // msgBytes Uns(5);
       End-Pi;


       // Params
       Dcl-S msg Uns(3) Dim(1024);
       Dcl-S msgBytes Uns(5);


       // Variables
       Dcl-S k Uns(20) Dim(64);         // round constants
       Dcl-S hash Uns(20) Dim(8);       // hash to return
       Dcl-S msgBits Uns(5);            // message size in bits
       Dcl-S numBlocks Uns(3) Inz(17);  // blocks needed to hash msg (max)
       Dcl-S paddedMsg Uns(20) Dim(272);// 16*17

       Dcl-S w Uns(20) Dim(64);         // message schedule array
       Dcl-S s0 Uns(20);                // temp s0
       Dcl-S s1 Uns(20);                // temp s1
       Dcl-S t0 Uns(20);                // temp t0
       Dcl-S t1 Uns(20);                // temp t1

       Dcl-S a Uns(20);                 // A register
       Dcl-S b Uns(20);                 // B register
       Dcl-S c Uns(20);                 // C register
       Dcl-S d Uns(20);                 // D register
       Dcl-S e Uns(20);                 // E register
       Dcl-S f Uns(20);                 // F register
       Dcl-S g Uns(20);                 // G register
       Dcl-S h Uns(20);                 // H register

       Dcl-S i Uns(20);                 // iterator
       Dcl-S j Uns(20);                 // iterator


       Dsply ('Running SHA-256 test...');


       // Init constants
       ExSr InitHash;
       ExSr InitRoundConstants;


       // TESTING...Pretend this was passed to the program
       msgBytes = 3;
       msg(1) = X'81';
       msg(2) = X'cd';
       msg(3) = X'02';
       // test hash:
       // 4189c360b244d82b862073dc4c2e5a23e40bc86aa118ed854e755b335e126983


       // Pre-Processing
       msgBits = msgBytes * 8;
       numBlocks = 1 + ((msgBits + 80) / 512);
       // Dsply ('msgBits = ' + %Char(msgBits));
       // Dsply ('msgBytes = ' + %Char(msgBytes));
       // Dsply ('numBlocks = ' + %Char(numBlocks));

       For i = 1 To msgBytes;
         paddedMsg(i) = msg(i);
       EndFor;
       paddedMsg(msgBytes + 1) = X'80'; //append 1 in big endian

       // Convert from little to big endian
       For i = 1 To (numBlocks * 16);
         // Dsply (%Char(i) + ' before: ' + %Char(paddedMsg(i)));
         paddedMsg(i) = EndianL2B(paddedMsg(i));
         // Dsply (%Char(i) + ' after:  ' + %Char(paddedMsg(i)));
       EndFor;

       // Dsply ('val ' + %Char(%Int(((numBlocks * 512 - 64) / 32)+1)));
       paddedMsg(%Int(((numBlocks * 512 - 64) / 32) + 1)) = msgBits;

       // Break message into 512-bit chunks
       For i = 1 To numBlocks;

          For j = 1 To 64;
            w((512 * (i - 1)) + j) = paddedMsg((16 * (i - 1)) + j);
          EndFor;

          // Extend first 16 words to w[16..63] of message schedule array
          For j = 16 to 64;
            s0 = %BitXor(RotateRight(w(j-15):7):RotateRight(w(j-15):18));
            s0 = %BitXor(s0:ShiftRight(w(j-15):3));
            s1 = %BitXor(RotateRight(w(j-2):17):RotateRight(w(j-2):19));
            s1 = %BitXor(s1:ShiftRight(w(j-2):10));
          EndFor;

          // Init registers to current hash values
          a = hash(1);
          b = hash(2);
          c = hash(3);
          d = hash(4);
          e = hash(5);
          f = hash(6);
          g = hash(7);
          h = hash(8);

          // Compression function
          For j = 1 To 64;
            t0 = h + BigSig1(e) + Choose(e:f:g) + k(j) + w(j);
          //t1 = BigSig0(a) + Major(a:b:c);
          //t0 = 0;
            t1 = 0;
            h = g;
            g = f;
            f = e;
            e = d + t0;
            d = c;
            c = b;
            b = a;
            a = t0 + t1;
          EndFor;

          // Add compressed chunk to current hash val
          hash(1) = hash(1) + a;
          hash(2) = hash(2) + b;
          hash(3) = hash(3) + c;
          hash(4) = hash(4) + d;
          hash(5) = hash(5) + e;
          hash(6) = hash(6) + f;
          hash(7) = hash(7) + g;
          hash(8) = hash(8) + h;

       EndFor;

       For i = 1 To 64;
         //Dsply ( 'w(' + %Char(i) + ') = ' + %Char(w(i)) );
       EndFor;

       Dsply ('Success.');


       *INLR = *ON;


       // +---------------------------------------------------------+
       // |                       Subroutines                       |
       // +---------------------------------------------------------+

       // Init hash -> first 32-bits of fractional parts of
       //    square roots of first 8 primes [2..19]
       BegSr InitHash;
         hash(1) = X'6a09e667';
         hash(2) = X'bb67ae85';
         hash(3) = X'3c6ef372';
         hash(4) = X'a54ff53a';
         hash(5) = X'510e527f';
         hash(6) = X'9b05688c';
         hash(7) = X'1f83d9ab';
         hash(8) = X'5be0cd19';
       EndSr;

       // Init round constants -> first 32-bits of fractional parts
       //    of the cube roots of the first 64 primes [2..311]
       // Might be a good idea to use a table, but maybe this is "faster"?
       BegSr InitRoundConstants;
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
       EndSr;

       // +---------------------------------------------------------+
       // |                        Procedures                       |
       // +---------------------------------------------------------+

       Dcl-Proc ShiftLeft;
         Dcl-Pi *N Uns(20);
           x       Uns(20);
           shift   Uns(20) const;
         End-Pi;
         return x * %UnsH(2 ** shift);
       End-Proc;

       Dcl-Proc ShiftRight;
         Dcl-Pi *N Uns(20);
           x       Uns(20);
           shift   Uns(20) const;
         End-Pi;
         return %Div(x : %UnsH(2 ** shift));
       End-Proc;

       Dcl-Proc EndianL2B;
         Dcl-Pi *N Uns(20);
           x       Uns(20);
         End-Pi;
         Dcl-S val Uns(20);
         val = %BitAnd(ShiftLeft(x:8):x'ff00ff00');
         val = %BitOr(%BitAnd(ShiftRight(x:8):x'ff00ff'):val);
         return %BitOr(ShiftLeft(val:16):ShiftRight(val:16));
       End-Proc;

       Dcl-Proc RotateRight;
         Dcl-Pi *N Uns(20);
           x       Uns(20);
           rot     Uns(20) const;
         End-Pi;
         return %BitOr(ShiftRight(x:rot):ShiftLeft(x:(32-rot)));
       End-Proc;

       Dcl-Proc RotateLeft;
         Dcl-Pi *N Uns(20);
           x       Uns(20);
           rot     Uns(20) const;
         End-Pi;
         return %BitOr(ShiftLeft(x:rot):ShiftRight(x:(32-rot)));
       End-Proc;

       Dcl-Proc Choose;
         Dcl-Pi *N Uns(20);
           x       Uns(20);
           y       Uns(20);
           z       Uns(20);
         End-Pi;
         Dcl-S left Uns(20);
         left = %BitAnd(x:y);
         return %BitXor(left:(%BitAnd(%BitNot(x):z)));
       End-Proc;

       Dcl-Proc Major;
         Dcl-Pi *N Uns(20);
           x       Uns(20);
           y       Uns(20);
           z       Uns(20);
         End-Pi;
         Dcl-S val Uns(20);
         val = %BitXor(%BitAnd(x:y):%BitAnd(x:z));
         return %BitXor(val:%BitAnd(y:z));
       End-Proc;

       Dcl-Proc BigSig0;
         Dcl-Pi *N Uns(20);
           x       Uns(20);
         End-Pi;
         Dcl-S val Uns(20);
         val = %BitXor(RotateRight(x:2):RotateRight(x:13));
         return %BitXor(val:RotateRight(x:22));
       End-Proc;

       Dcl-Proc BigSig1;
         Dcl-Pi *N Uns(20);
           x       Uns(20);
         End-Pi;
         Dcl-S val Uns(20);
         Monitor;
           val = %BitXor(RotateRight(x:6):RotateRight(x:11));
           val = %BitXor(val:RotateRight(x:25));
           On-Error;
             Dsply ('BigSig1() failed');
             Dsply (' x   = ' + %char(x));
             Dsply (' val = ' + %char(val));
         EndMon;
         return val;
       End-Proc;

       Dcl-Proc LilSig0;
         Dcl-Pi *N Uns(20);
           x       Uns(20);
         End-Pi;
         Dcl-S val Uns(20);
         val = %BitXor(RotateRight(x:7):RotateRight(x:18));
         return %BitXor(val:ShiftRight(x:3));
       End-Proc;

       Dcl-Proc LilSig1;
         Dcl-Pi *N Uns(20);
           x       Uns(20);
         End-Pi;
         Dcl-S val Uns(20);
         val = %BitXor(RotateRight(x:17):RotateRight(x:19));
         return %BitXor(val:ShiftRight(x:10));
       End-Proc;






