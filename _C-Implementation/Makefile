default: build

build:
	clear
	gcc -o testsha -std=c99 -Wall -g -Werror -rdynamic sha256.c sha256_test.c -lm
	gcc -o testbtc -std=c99 -Wall -g  -rdynamic sha256.c btcHash.c -lm
test-btc:
	clear
	gcc -o testbtc -std=c99 -Wall -g -Werror -rdynamic sha256.c btcHash.c -lm
	./testbtc
test-sha:
	clear
	gcc -o testsha -std=c99 -Wall -g -Werror -rdynamic sha256.c sha256_test.c -lm
	./testsha
dbg-sha:
	clear
	gcc -o testsha -std=c99 -Wall -g -Werror -rdynamic sha256.c sha256_test.c  -lm
	./testsha
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose --log-file=valgrind-out_sha.txt ./testsha
dbg-btc:
	clear
	gcc -o testbtc -std=c99 -Wall -g -Werror -rdynamic sha256.c btcHash.c -lm
	./testbtc
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose --log-file=valgrind-out_btc.txt ./testbtc
clean:
	rm -rf testbtc testsha valgrind-out_sha.txt valgrind-out_btc.txt
