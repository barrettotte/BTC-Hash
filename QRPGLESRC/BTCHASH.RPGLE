     **Free
       // Scuffed BTC Hash Implementation
       // Barrett Otte 2019
       // https://github.com/barrettotte/RPGLE-BTC-Hash


       Ctl-Opt DftActGrp(*No) Option(*SrcStmt: *NoDebugIO);

       Dcl-Pr Main ExtPgm('BTCHASH');
         // ?
       End-Pr;

       // Prototypes
       Dcl-Pr Sha256 ExtProc('Qc3CalculateHash');
         Dcl-S inData Pointer value;
         Dcl-S inDataL Int(10) const;
         Dcl-S inDataF Char(8) const;
         Dcl-S algoDes Char(16) const;
         Dcl-S algoFmt Char(8) const;
         Dcl-S cryptoSP Char(1) const;
         Dcl-S cryptoDev Char(1) const options(*omit);
         Dcl-S hash Char(64) options(*varsize:*omit);
         Dcl-S errorCode Char(32767) options(*varsize);
       End-Pr;

       Dcl-Ds Alg_t Qualified Based(Template);
         Dcl-S hashAlg Int(10);
       End-Ds;



       Dsply ('Hello world');


       *Inlr=*On;


