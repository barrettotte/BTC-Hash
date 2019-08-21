# RPGLE Notes


My RPGLE is far weaker than my C, so any gotchas or things I should remember I'll put in here.
There's no way that translating from C to RPGLE is going to be painless, so its going to be interesting.


## TODO
* Move hash init and k[] init to a subroutine at bottom




## Data Types
| C        | RPGLE   | Bytes |
| -------- | ------- | ----- |
| uint8_t  | Uns(3)  | 1     |
| uint16_t | Uns(5)  | 2     |
| uint32_t | Uns(10) | 4     |


## General things I dont want to forget
* Turn off syntax checking for SEU -> F13
* ```DSPLY('HELLO');``` = compile error; Don't forget the space.  ```DSPLY ('HELLO')```
* Right click emulator > Sysreq > 3


## Hex numbers (Little Endian)

Initial Hash Values
| Hex         | Unsigned Int |
| ----------- | ------------ |
| X'6a09e667' | 1779033703   |
| X'bb67ae85' | 3144134277   |
| X'3c6ef372' | 1013904242   |
| X'a54ff53a' | 2773480762   |
| X'510e527f' | 1359893119   |
| X'9b05688c' | 2600822924   |
| X'1f83d9ab' | 528734635    |
| X'5be0cd19' | 1541459225   |


## Implementation Differences
* Limited msg to 1024 bytes, therefore a lot more hardcoding values to match max allowable
* 

