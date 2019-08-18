#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h> 
#include "sha256.h"

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

void printHash(unsigned char* h) {
    for(int i = 31; i >= 0; i--){
        char str[3];
        sprintf(str, "%02x", h[i]);
        printf("%s", str);
    }
}

void printHashRate(clock_t start, uint32_t nonce){
    printf("%15s", " Hash Rate: ");
    printf("%10f kH/s\n", (1000.0/(clock()-start))*nonce);
}

uint32_t swap(uint32_t val){
    val = ((val << 8) & 0xFF00FF00 ) | ((val >> 8) & 0xFF00FF );
    return (val << 16) | (val >> 16);
}

int main() {
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
      "020000000000000000000009c2e82d884ec07b4aafb64ca3ef83baca2b6b0b5eb72c8f0216ec1eafaca8ca59d182cbf94f29b50b06ac4207b883f380b9bf547fe8fed72351FCF9471972DBF200917661"
    }; // cdbedd22b3a25804eea6d99d33af6541442f33929d38f115c42c22560c3e65c
       // cdbedd22b3a25804eea6d99d033af6541442f33929d38f115c42c22560c3e65c   ???? WHAT

    //uint32_t targetNonce = 9533025; // 
    //uint32_t rounds = 1000000;
    uint32_t nonce = 0;//targetNonce-rounds;
    uint32_t hash1[8], hash2[8];
    clock_t start = clock();

    while(1){
        //header[76] = (nonce >> 0) & 0xFF;  
        //header[77] = (nonce >> 8) & 0xFF;
        //header[78] = (nonce >> 16) & 0xFF; 
        //header[79] = (nonce >> 24) & 0xFF;
        
        sha256_hash(header, hash1);
        for (int i = 0; i < 8; i++){
		    printf("%.2x", hash1[i]);
	    }
        printf("\nstrlen hash1 -- %d bytes", (int) strlen((char *) hash1));
        printf("\nsizeof hash1 -- %d bytes\n", (int)sizeof hash1);
        printf("\n");

        // target: 5a51e9cb50e28e5b0e894458c88b980f9c8c05abb48efae1658c1d64a635708c

        // uint32_t swapped[8];
        // for(int i = 0; i < 8; i++){
        //     swapped[i] = swap(hash1[i]);
        // }

        uint8_t tmp[32];
        //memcpy(tmp, swapped, 32);
        memcpy(tmp, hash1, 32);

        printf("\n");
        sha256_hash(tmp, hash2);
        //sha256_hash((uint8_t*) hash1, hash2);

        printHash((uint8_t*)hash2);
        printf("\n");
        for (int i = 0; i < 8; i++){
		    printf("%.2x", hash2[i]);
	    }
        printf("\nstrlen hash2 -- %d bytes", (int) strlen((char *) hash2));
        printf("\nsizeof hash2 -- %d bytes\n", (int)sizeof hash2);
        printf("\n");
        
        if(nonce % 25000 == 0){
            //printf("Nonce %8d : ", nonce);
            //printHash((uint8_t*) hash2);
            printHashRate(start, nonce);
        }
        if(checkHash(hash2)){
            break;
        }
        break;
        nonce++;
    }
    return 0;
}