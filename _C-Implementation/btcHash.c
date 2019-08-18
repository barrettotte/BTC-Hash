#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h> 
#include "sha256.h"


// http://cs-fundamentals.com/tech-interview/c/c-program-to-check-little-and-big-endian-architecture.php
void checkEndian(){
    unsigned int x = 0x76543210;
    char *c = (char*) &x;
    printf ("*c is: 0x%x\n", *c);
    if (*c == 0x10) {
        printf ("Underlying architecture is little endian.\n");
    }
    else {
        printf ("Underlying architecture is big endian.\n");
    }
}

// Check first 9 digits for 0
int checkHash(uint32_t* s){
    int valid = 1;
    for(uint8_t i=31; i>22; i--){
        if(s[i] != 0){
            valid = 0;
        }
    }
    return valid;
}

void printHashRate(clock_t start, uint32_t nonce){
    printf("%15s", " Hash Rate: ");
    printf("%10f kH/s\n", (1000.0/(clock()-start))*nonce);
}

void printHash(uint32_t h[8]){
    for(int i = 0; i < 8; i++){
		printf("%08jx", (uintmax_t)h[i]);
	}
}

uint32_t bigToLittleEndian(uint32_t val){
    return ((val >> 24) & 0xff)      |   // byte 3 to byte 0
           ((val << 8)  & 0xff0000)  |   // byte 1 to byte 2
           ((val >> 8)  & 0xff00)    |   // byte 2 to byte 1
           ((val << 24) & 0xff000000);   // byte 0 to byte 3
}

int main() {
    // checkEndian(); // little
    /* Block Header:
        - Block version: 2
        - Hash prev block header
        - Hash of merkle root
        - unix timestamp  1375533383 -> (2013-08-03 12:36:23)
        - Bits (current target)
        - Nonce
    */
    // https://www.blockchain.com/btc/block-height/250000
    uint8_t header[] = {
      //"020000000000000000000009c2e82d884ec07b4aafb64ca3ef83baca2b6b0b5eb72c8f0216ec1eafaca8ca59d182cbf94f29b50b06ac4207b883f380b9bf547fe8fed72351FCF9471972DBF200917661"
      0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x09,0xc2,0xe8,0x2d,0x88,0x4e,0xc0,0x7b,0x4a,
      0xaf,0xb6,0x4c,0xa3,0xef,0x83,0xba,0xca,0x2b,0x6b,0x0b,0x5e,0xb7,0x2c,0x8f,0x02,0x16,0xec,0x1e,0xaf,
      0xac,0xa8,0xca,0x59,0xd1,0x82,0xcb,0xf9,0x4f,0x29,0xb5,0x0b,0x06,0xac,0x42,0x07,0xb8,0x83,0xf3,0x80,
      0xb9,0xbf,0x54,0x7f,0xe8,0xfe,0xd7,0x23,0x51,0xFC,0xF9,0x47,0x19,0x72,0xDB,0xF2,0x00,0x91,0x76,0x61
    }; 
    // hash1: a176abc01d8c2a7f1c002b0ebd21eeeb1219de84b8b69ff2096820153b597213
    // hash2: 7161b22d692b1d76693e6b19fc8482bf41cda5ef66fc81f6ddbc6d982ff1e972

    uint32_t targetNonce = 9533025; // 
    uint32_t rounds = 10000;
    uint32_t nonce = 0;//targetNonce - rounds;
    uint32_t hash1[8], hash2[8];
    clock_t start = clock();

    while(1){
        header[76] = (nonce >> 0)  & 0xFF;  
        header[77] = (nonce >> 8)  & 0xFF;
        header[78] = (nonce >> 16) & 0xFF; 
        header[79] = (nonce >> 24) & 0xFF;
        
        sha256_hash(header, (uint64_t)80, hash1); //hash1 -> returns big endian
        uint32_t swapped[8]; // swap from big to little endian
        for(int i = 0; i < 8; i++){
            swapped[i] = bigToLittleEndian(hash1[i]);
        }
        sha256_hash((uint8_t*)swapped, (uint64_t) 32, hash2);
        if(nonce % 100000 == 0){
            printf("Nonce %8d : ", nonce);
            printHash(hash2);
            printHashRate(start, nonce);
        }
        if(checkHash(hash2)){
            break;
        }
        nonce++;
    }
    return 0;
}