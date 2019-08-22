     **Free
       // Scuffed SHA-256 implementation
       // Barrett Otte 2019
       // https://github.com/barrettotte/RPGLE-BTC-Hash


       Ctl-Opt DftActGrp(*No) Option(*SrcStmt: *NoDebugIO);


       Dcl-Pr Main ExtPgm('SHA256');
        // msg      Uns(3) Dim(1024);
        // msgBytes Uns(5);
       End-Pr;   // TODO: Find out why this is needed


       // C Prototypes  (Also known as cheating)
       Dcl-Pr Memcpy ExtProc('__memcpy');
         pTarget Pointer value;
         pSource Pointer value;
         nLength Uns(10) value;
       End-Pr;

       Dcl-Pr Memset ExtProc('__memset');
         pTarget Pointer value;
         nChar Int(10) value;
         nBufLen Uns(10) value;
       End-Pr;


       // Params
          Dcl-S msg Uns(3) Dim(512);
          Dcl-S msgBytes Uns(20);
       // Dcl-S msg Pointer;

       // Variables
       Dcl-S k Uns(10) Dim(64);           // round constants
       Dcl-S hash Uns(10) Dim(8);         // hash to return
       Dcl-S msgBits Uns(20);             // message size in bits
       Dcl-S buffPtr Pointer;             // pointer to msgBuffer
       Dcl-S msgBuffer Uns(10) Dim(16);   // uint32 [16]
       Dcl-S w Uns(10) Dim(64);           // message schedule array [MSA]
       Dcl-S s0 Uns(10);                  // MSA tmp var
       Dcl-S s1 Uns(10);                  // MSA tmp var
       Dcl-S t0 Uns(10);                  // compression func tmp var
       Dcl-S t1 Uns(10);                  // compression func tmp var

       Dcl-S a Uns(10);                   // register A  hash[0..3]
       Dcl-S b Uns(10);                   // register B  hash[4..7]
       Dcl-S c Uns(10);                   // register C  hash[8..11]
       Dcl-S d Uns(10);                   // register D  hash[12..15]
       Dcl-S e Uns(10);                   // register E  hash[16..19]
       Dcl-S f Uns(10);                   // register F  hash[20..23]
       Dcl-S g Uns(10);                   // register G  hash[24..27]
       Dcl-S h Uns(10);                   // register H  hash[28..31]

       // Junk Variables
       Dcl-S i Uns(10);                   // iterator
       Dcl-S j Uns(10);                   // iterator


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


       // Sanity checking bitwise functions
       //For i = 1 to 3;
       //  Dsply ('msg(' + %Char(i) + ') = ' + %Char(msg(i)));
       //  Dsply (%Char(ShiftRight(msg(i):2)));
       //  Dsply (%Char(ShiftLeft(msg(i):10)));
       //  Dsply (%Char(RotateRight(msg(i):4)));
       //  Dsply (%Char(RotateLeft(msg(i):16)));
       //  Dsply (%Char(EndianL2B(msg(i))));
       //EndFor;
       //Dsply (%Char(Choose(msg(1):msg(2):msg(3))));


       msgBits = msgBytes * 8;

       Memcpy(%Addr(msgBuffer) : %Addr(msg) : msgBytes);
       msgBuffer(msgBytes + 1) = X'80'; // append 1 in big endian

       // Convert from little to big endian
       For i = 1 To msgBytes;
         msgBuffer(i) = EndianL2B(i);
       EndFor;

       // Copy block to w[0..15] of message schedule array
       Memcpy(%Addr(w) : %Addr(msgBuffer) : 512);

       // Extend first 16 words to w[16..63] of message schedule array
       For i = 17 To 64;
         s0 = %BitXor(RotateRight(w(i-15):18) : ShiftRight(w(i-15):3));
         s0 = %BitXor(RotateRight(w(i-15):7) : s0);
         s1 = %BitXor(RotateRight(w(i-2):19) : ShiftRight(w(i-2):10));
         s1 = %BitXor(RotateRight(w(i-2):17) : s1);
         w(i) = w(i-16) + s0 + w(i-7) + s1;
       EndFor;

       // Init registers to current hash value
       a = hash(1);
       b = hash(2);
       c = hash(3);
       d = hash(4);
       e = hash(5);
       f = hash(6);
       g = hash(7);
       h = hash(8);

       // Compression function
       For i = 1 To 64;
         t0 = h + BigSig1(e) + Choose(e:f:g) + k(i) + w(i);
         t1 = BigSig0(a) + Major(a:b:c);
         h = g;
         g = f;
         e = d + t0;
         d = c;
         c = b;
         b = a;
         a = t0 + t1;
       EndFor;

       // Add compressed block to current hash val
       hash(1) = hash(1) + a;
       hash(2) = hash(2) + b;
       hash(3) = hash(3) + c;
       hash(4) = hash(4) + d;
       hash(5) = hash(5) + e;
       hash(6) = hash(6) + f;
       hash(7) = hash(7) + g;
       hash(8) = hash(8) + h;


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
           x       Uns(20) const;
           shift   Uns(20) const;
         End-Pi;
         return x * %UnsH(2 ** shift);
       End-Proc;

       Dcl-Proc ShiftRight;
         Dcl-Pi *N Uns(20);
           x       Uns(20) const;
           shift   Uns(20) const;
         End-Pi;
         return %Div(x : %UnsH(2 ** shift));
       End-Proc;

       Dcl-Proc EndianL2B;
         Dcl-Pi *N Uns(20);
           x       Uns(20) const;
         End-Pi;
         Dcl-S val Uns(20);
         val = %BitAnd(ShiftLeft(x:8):x'ff00ff00');
         val = %BitOr(%BitAnd(ShiftRight(x:8):x'ff00ff'):val);
         return %BitOr(ShiftLeft(val:16):ShiftRight(val:16));
       End-Proc;

       Dcl-Proc RotateRight;
         Dcl-Pi *N Uns(20);
           x       Uns(20) const;
           rot     Uns(20) const;
         End-Pi;
         return %BitOr(ShiftRight(x:rot):ShiftLeft(x:(32-rot)));
       End-Proc;

       Dcl-Proc RotateLeft;
         Dcl-Pi *N Uns(20);
           x       Uns(20) const;
           rot     Uns(20) const;
         End-Pi;
         return %BitOr(ShiftLeft(x:rot):ShiftRight(x:(32-rot)));
       End-Proc;

       Dcl-Proc Choose;
         Dcl-Pi *N Uns(20);
           x       Uns(20) const;
           y       Uns(20) const;
           z       Uns(20) const;
         End-Pi;
         return %BitXor(%BitAnd(x:y):(%BitAnd(%BitNot(x):z)));
       End-Proc;

       Dcl-Proc Major;
         Dcl-Pi *N Uns(20);
           x       Uns(20) const;
           y       Uns(20) const;
           z       Uns(20) const;
         End-Pi;
         return %BitXor(%BitXor(%BitAnd(x:y):%BitAnd(x:z)):%BitAnd(y:z));
       End-Proc;

       Dcl-Proc BigSig0;
         Dcl-Pi *N Uns(20);
           x       Uns(20) const;
         End-Pi;
         Dcl-S val Uns(20);
         val = %BitXor(RotateRight(x:2):RotateRight(x:13));
         return %BitXor(val:RotateRight(x:22));
       End-Proc;

       Dcl-Proc BigSig1;
         Dcl-Pi *N Uns(20);
           x       Uns(20) const;
         End-Pi;
         Dcl-S val Uns(20);
         val = %BitXor(RotateRight(x:6):RotateRight(x:11));
         return %BitXor(val:RotateRight(x:25));
       End-Proc;

       Dcl-Proc LilSig0;
         Dcl-Pi *N Uns(20);
           x       Uns(20) const;
         End-Pi;
         Dcl-S val Uns(20);
         val = %BitXor(RotateRight(x:7):RotateRight(x:18));
         return %BitXor(val:ShiftRight(x:3));
       End-Proc;

       Dcl-Proc LilSig1;
         Dcl-Pi *N Uns(20);
           x       Uns(20) const;
         End-Pi;
         Dcl-S val Uns(20);
         val = %BitXor(RotateRight(x:17):RotateRight(x:19));
         return %BitXor(val:ShiftRight(x:10));
       End-Proc;






