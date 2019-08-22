# Sanity checking some functions

def rot32_r(x,n): return (x >> n) | (x << (32 - n))
def rot32_l(x,n): return (x << n) | (x >> (32 - n))

def endian_l2b(x):
    val = ((x << 8) & 0xFF00FF00 ) | ((x >> 8) & 0xFF00FF )
    return (val << 16) | (val >> 16)

def choose(x,y,z): return (x & y) ^ (~x & z)

x = 129 # 0x81
print(x >> 2)  # 32
print(x << 10) # 132096
print(rot32_r(x,4)) # 3462817832
print(rot32_l(x,16)) # 8454144
print(endian_l2b(x)) # 2164260864

print("")
y = 205 #0xcd 
print(y >> 2)  # 51
print(y << 10) # 209920
print(rot32_r(y,4)) # 55029268492
print(rot32_l(y,16)) # 13434880
print(endian_l2b(y)) # 3439329280


print("")
z = 2 # 0x02
print(z >> 2)  # 0
print(z << 10) # 2048
print(rot32_r(z,4)) # 53670912
print(rot32_l(z,16)) # 131072
print(endian_l2b(z)) # 33554432

print("")
print(choose(x,y,z))