
ns = set()
BITSIZE, conv = 6, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-=_+[]{}\\|/,.<>;:'\"`~"
BITSIZE, conv = 6, "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ#@"
ranges = [
    range(0x21, 0x7e + 1),
    range(0xa1, 0xac + 1),
    range(0xae, 0xff + 1),
]
# BITSIZE, conv = 7, ''.join(chr(c) for r in ranges for c in r)
def encode(b):
    s = ""
    while b:
        n = b & (2**BITSIZE - 1)
        ns.add(n)
        c = conv[n]
        b >>= BITSIZE
        s += c
    return s


def decode(s):
    b = 0
    for c in s[::-1]:
        b <<= BITSIZE
        n = conv.index(c)
        b += n
    return b


b = 0b10010111010111011011010101111001001100110011001100110011001100110010001000100010001000100010001010000110010011001010010001101000111111111111111100000000000000000000000010000000011111111111111111111
s = encode(b)
de = decode(s)
print(s, len(s), sep=" ")
print(f"0b{b:0197b}e")
print(f"0b{de:0197b}e")
print(f"0b{de^b:0197b}e")
assert b == de
# de2 = decode("ÃÃ`!\"!!´Ã`UE::5Ce)2T©m:4P±O8\"")
# print()
# print(f"0b{b:0197b}e")
# print(f"0b{de2:0197b}e")
# print(f"0b{de2^b:0197b}e")
# assert b == de2
byt = bytes(s, encoding='utf-8')
print(byt)
print([*map(int, byt)])
print(ns)
print(conv)

