#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "sha256.h"


/* Test vectors provided by https://www.di-mgt.com.au/sha_testvectors.html
   (Skipped test vector 6 out of laziness) */

void printHash(uint32_t* hash){
    printf("  Actual:   ");
    for (int i = 0; i < 8; i++){
		printf("%.2x ", hash[i]);
	}
}

void hex2bin(unsigned char *dest, const unsigned char *src) {
    int c, pos;
    char buf[3];
    pos = 0;
    c = 0;
    buf[2] = 0;
    while (c < strlen((char*)src)) {
        buf[0] = src[c++];
        buf[1] = src[c++];
        dest[pos++] = (unsigned char)strtol(buf, NULL, 16);
    }
}

void testBlockHash(){
    printf("\nTest Block Hash\n");
    uint32_t hash[8];
    const uint8_t msg[] = {
      "0100000081cd02ab7e569e8bcd9317e2fe99f2de44d49ab2b8851ba4a308000000000000e320b6c2fffc8d750423db8b1eb942ae710e951ed797f7affc8892b0f1fc122bc7f5d74df2b9441a42a14695"
    };
    calculateHash(msg, hash);
    printHash(hash);
    printf("\n  Expected: 38f1abde cb7e001a b403aecd 885a010d 5a254054 e479d335 273eaa1c bdd62674\n");
}

void testVector1(){
    printf("\nTest Vector 1:\n");
    uint32_t hash[8];
    const uint8_t msg[] = { 'a','b','c' };
    calculateHash(msg, hash);
    printHash(hash);
    printf("\n  Expected: ba7816bf 8f01cfea 414140de 5dae2223 b00361a3 96177a9c b410ff61 f20015ad\n");
}

void testVector2(){
    printf("\nTest Vector 2:\n");
    uint32_t hash[8];
    const uint8_t msg[] = { "" };
    calculateHash(msg, hash);
    printHash(hash);
    printf("\n  Expected: e3b0c442 98fc1c14 9afbf4c8 996fb924 27ae41e4 649b934c a495991b 7852b855\n");
}

void testVector3(){
    printf("\nTest Vector 3:\n");
    uint32_t hash[8];
    const uint8_t msg[] = { 'a','b','c','d','b','c','d','e','c','d','e','f','d','e','f',
        'g','e','f','g','h','f','g','h','i','g','h','i','j','h','i','j','k','i','j','k',
        'l','j','k','l','m','k','l','m','n','l','m','n','o','m','n','o','p','n','o','p','q' };
    calculateHash(msg, hash);
    printHash(hash);
    printf("\n  Expected: 248d6a61 d20638b8 e5c02693 0c3e6039 a33ce459 64ff2167 f6ecedd4 19db06c1\n");
}

void testVector4(){
    printf("\nTest Vector 4:\n");
    uint32_t hash[8];
    const uint8_t msg[] = { "abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu" };
    calculateHash(msg, hash);
    printHash(hash);
    printf("\n  Expected: cf5b16a7 78af8380 036ce59e 7b049237 0b249b11 e8f07a51 afac4503 7afee9d1\n");
}

int main() {
    testVector1();
    testVector2();
    testVector3();
    testVector4();
    testBlockHash();  
    return 0;
}