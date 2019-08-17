# IBMi-BTC-Hash


A really stupid side project to see if I could make the bitcoin hashing and SHA-256 algorithms in only RPGLE.

I also wanted some more practice with programming in RPGLE and thought this would be the perfect opportunity (why I thought that is beyond me).



## SHA-256
For sanity's sake, I prototyped the whole thing in C first using the 
[SHA-256 specification](http://csrc.nist.gov/publications/fips/fips180-2/fips180-2withchangenotice.pdf)
and some [pseudocode](https://en.wikipedia.org/wiki/SHA-2#pseudocode). 
This implementation is probably slow and efficient. 
I don't really know better honestly, I'm just assuming since my C is pretty weak.
Then it was "just" a translation from C to RPGLE.


I saw a lot of implementations had multiple functions (init,process,final) and a sha256_context struct. 
For my purposes I thought it was kind of overkill to go that route, so I made a function
to produce the SHA-256 digest in one call rather than 3.


## Bitcoin Hashing Algorithm



## References
* BTC Protocol https://en.bitcoin.it/wiki/Protocol_documentation
* BTC mining the hard way http://www.righto.com/2014/02/bitcoin-mining-hard-way-algorithms.html
* Pre-mined block used for POC https://www.blockchain.com/btc/block/000000000000003887df1f29024b06fc2200b55f8af8f35453d7be294df2d214
* Test vectors for SHA https://www.di-mgt.com.au/sha_testvectors.html
* SHA-256 calculator https://www.xorbin.com/tools/sha256-hash-calculator
* SHA-256 pseudocode https://en.wikipedia.org/wiki/SHA-2#pseudocode
* SHA-256 spec http://csrc.nist.gov/publications/fips/fips180-2/fips180-2withchangenotice.pdf

