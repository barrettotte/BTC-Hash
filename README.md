# RPGLE-BTC-Hash


A really stupid side project idea I thought of driving to work one morning. I wanted to see if I could make the bitcoin hashing and SHA-256 algorithms in only RPGLE.

I also wanted some more practice with programming in RPGLE and thought this would be the perfect opportunity (why I thought that is beyond me).

**However, I got too ambitious and couldn't get it done in the end.**


## SHA-256
For sanity's sake, I prototyped the whole thing in C first using the 
[SHA-256 specification](http://csrc.nist.gov/publications/fips/fips180-2/fips180-2withchangenotice.pdf)
and some [pseudocode](https://en.wikipedia.org/wiki/SHA-2#pseudocode). Then it was "just" a translation from C to RPGLE.


I saw a lot of implementations had multiple functions (init,process,final) and a sha256_context struct. 
For my purposes I thought it was kind of overkill to go that route, so I made a function
to produce the SHA-256 digest in one call rather than 3.


## Bitcoin Hashing Algorithm
I followed the logic laid out on the [bitcoin wiki](https://en.bitcoin.it/wiki/Block_hashing_algorithm) for the
hashing algorithm. The hardest part was getting my double SHA-256 hash working correctly 
(it took me 2 hours to realize I was using the wrong endianness)


## C Implementation Sample
Calculating/outputting hash rate every 100,000 iterations.

```
Nonce  1500000 : 41b76de4a780eda162e312ef989501326a115ea879a1fa615a326d5cc88e10df    Hash Rate: 196.840578 kH/s
Nonce  1600000 : fd550eac652dde1d6d6b9525dacce686cf4f59aa237f98c93d508b485578a6d9    Hash Rate: 196.841893 kH/s
Nonce  1700000 : 659e8fc9b7c915d1591218036f569c09895703b91051591dd9ae1afe40a16833    Hash Rate: 197.170350 kH/s
Nonce  1800000 : bf243bd487a79ac57ad2eabcd1619d6b665cc9c11a75e1c5446a7bd165246409    Hash Rate: 197.335943 kH/s
Nonce  1900000 : e58bc951d6db6c19b03a191a6f57184ef0a66c77793ee2cbe0e5d85622e8ce1e    Hash Rate: 196.960608 kH/s
Nonce  2000000 : 33bd6d0f054d21a860044af4107480150546f80fd80f4247ec19e4bbb72c969e    Hash Rate: 197.241110 kH/s
```


## RPGLE Implementation Sample
Well...I tried

But I don't think I am mentally there. I should do a different project for now...


## References
* Inspiration for the project [Mining BTC on the Apollo Guidance Computer](http://www.righto.com/2019/07/bitcoin-mining-on-apollo-guidance.html)
* BTC
  * Mined block used in implementation https://www.blockchain.com/btc/block-height/250000
  * BTC hashing algorithm https://en.bitcoin.it/wiki/Block_hashing_algorithm
  * BTC Protocol https://en.bitcoin.it/wiki/Protocol_documentation
  * BTC mining the hard way http://www.righto.com/2014/02/bitcoin-mining-hard-way-algorithms.html
* SHA-256 calculator
 * https://emn178.github.io/online-tools/sha256.html
 * https://www.fileformat.info/tool/hash.htm
* SHA-256
  * Test vectors for SHA https://www.di-mgt.com.au/sha_testvectors.html
  * SHA-256 pseudocode https://en.wikipedia.org/wiki/SHA-2#pseudocode
  * SHA-256 spec http://csrc.nist.gov/publications/fips/fips180-2/fips180-2withchangenotice.pdf
* RPG
  * Using C in RPG https://www.mcpressonline.com/programming/rpg/using-c-in-rpg-iv
  * https://www.redbooks.ibm.com/redbooks/pdfs/sg245402.pdf
  * Memory management operations https://www.ibm.com/support/knowledgecenter/en/ssw_ibm_i_74/rzasd/zzdeall.htm#zzdeall
  * Bit shifting in RPG https://stackoverflow.com/questions/44560356/bit-shifting-in-rpgle