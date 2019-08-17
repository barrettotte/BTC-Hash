/* 
  Subpar SHA-256 implementation
    - Pseudocode https://en.wikipedia.org/wiki/SHA-2#pseudocode
    - Spec http://csrc.nist.gov/publications/fips/fips180-2/fips180-2withchangenotice.pdf
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>


uint32_t rotateRight(uint32_t x, int n) {
    return (x >> n) | (x << (32 - n));
}

uint32_t rotateLeft(uint32_t x, int n) {
    return (x << n) | (x >> (32 - n));
}

uint32_t choose(uint32_t x, uint32_t y, uint32_t z) {
    return (x & y) ^ ((~x) & z);  // x input chooses output from y or z
}

uint32_t majority(uint32_t x, uint32_t y, uint32_t z) {
    return (x & y) ^ (x & z) ^ (y & z); // majority of 0/1's for each bit in x,y,z
}

uint32_t bigSig0(uint32_t x) {
    return rotateRight(x, 2) ^ rotateRight(x, 13) ^ rotateRight(x, 22);
}

uint32_t bigSig1(uint32_t x) {
    return rotateRight(x, 6) ^ rotateRight(x, 11) ^ rotateRight(x, 25);
}

uint32_t lilSig0(uint32_t x) {
    return rotateRight(x, 7) ^ rotateRight(x, 18) ^ (x >> 3);
}

uint32_t lilSig1(uint32_t x) {
    return rotateRight(x, 17) ^ rotateRight(x, 19) ^ (x >> 10);
}

uint32_t uint32Swap(uint32_t val){
    val = ((val << 8) & 0xFF00FF00 ) | ((val >> 8) & 0xFF00FF );
    return (val << 16) | (val >> 16);
}

void calculateHash(const uint8_t input[], uint32_t hash[8]){

    // Init hash -> first 32-bits of the fractional parts of the square roots of the first 8 primes [2..19]
    hash[0] = 0x6a09e667; hash[1] = 0xbb67ae85; hash[2] = 0x3c6ef372, hash[3] = 0xa54ff53a;
    hash[4] = 0x510e527f; hash[5] = 0x9b05688c; hash[6] = 0x1f83d9ab, hash[7] = 0x5be0cd19;

    // (first 32 bits of the fractional parts of the cube roots of the first 64 primes 2..311):
    const uint32_t k[64] = {
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
    };

    // Pre-processing
    uint64_t msgBytes = strlen((char *) input);
    uint64_t msgBits = msgBytes * 8;
    
    uint32_t numBlocks = 1 + ((msgBits + 16 + 64) / 512); //Round up num blocks needed
    uint32_t* paddedInput = calloc((512 / 32) * numBlocks, 32); // ((16) * num blocks, 32) (512 * num blocks [bits])
    memcpy(paddedInput, input, msgBytes);
    ((uint8_t*)paddedInput)[msgBytes] = 0x80; //append 1 bit in big-endian

    // convert from little to big-endian
    for(uint8_t i = 0; i < (numBlocks * 16) - 1; i++) {
        paddedInput[i] = uint32Swap(paddedInput[i]);
    }
    paddedInput[((numBlocks * 512 - 64) / 32) + 1] = msgBits;

    // break message into 512-bit chunks
    for(uint8_t i = 0; i < numBlocks; i++) {
        uint32_t* w = calloc(64, 32); // message schedule array [0..63] of 32-bit words
        memcpy(w, &paddedInput[i * 16], 512); // copy chunk into 16 words w[0..15] of message schedule array

        // Extend first 16 words into remaining 48 words w[16..63] of message schedule array
        for(uint8_t j = 16; j < 64; j++) {
            uint32_t s0 = rotateRight(w[j-15], 7) ^ rotateRight(w[j-15], 18) ^ (w[j-15] >> 3);
            uint32_t s1 = rotateRight(w[j-2], 17) ^ rotateRight(w[j-2], 19) ^ (w[j-2] >> 10);
            w[j] = w[j-16] + s0 + w[j-7] + s1;
        }

        //## Init vars to current hash val
        uint32_t a = hash[0]; uint32_t b = hash[1]; uint32_t c = hash[2]; uint32_t d = hash[3];
        uint32_t e = hash[4]; uint32_t f = hash[5]; uint32_t g = hash[6]; uint32_t h = hash[7];

        // Compression function
        for(uint8_t j = 0; j < 64; j++){
            uint32_t temp1 = h + bigSig1(e) + choose(e, f, g) + k[j] + w[j];
            uint32_t temp2 = bigSig0(a) + majority(a, b, c);
            h = g;
            g = f;
            f = e;
            e = d + temp1;
            d = c;
            c = b;
            b = a;
            a = temp1 + temp2;
        }
        // Add  compressed chunk to current hash val
        hash[0] += a; hash[1] += b; hash[2] += c; hash[3] += d;
        hash[4] += e; hash[5] += f; hash[6] += g; hash[7] += h;
        free(w);
    }
    free(paddedInput);
}