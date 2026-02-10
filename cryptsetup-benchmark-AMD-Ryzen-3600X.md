# Tests are approximate using memory only (no storage IO).
PBKDF2-sha1      2699037 iterations per second for 256-bit key
PBKDF2-sha256    5890876 iterations per second for 256-bit key
PBKDF2-sha512    2380422 iterations per second for 256-bit key
PBKDF2-ripemd160  985503 iterations per second for 256-bit key
PBKDF2-whirlpool  878204 iterations per second for 256-bit key
argon2i      10 iterations, 1048576 memory, 4 parallel threads (CPUs) for 256-bit key (requested 2000 ms time)
argon2id     10 iterations, 1048576 memory, 4 parallel threads (CPUs) for 256-bit key (requested 2000 ms time)
#     Algorithm |       Key |      Encryption |      Decryption
        aes-cbc        128b      1359,3 MiB/s      3777,3 MiB/s
    serpent-cbc        128b       136,5 MiB/s       933,8 MiB/s
    twofish-cbc        128b       271,6 MiB/s       494,6 MiB/s
        aes-cbc        256b      1040,9 MiB/s      3594,3 MiB/s
    serpent-cbc        256b       141,4 MiB/s       935,5 MiB/s
    twofish-cbc        256b       276,2 MiB/s       496,6 MiB/s
        aes-xts        256b      3517,8 MiB/s      3506,9 MiB/s
    serpent-xts        256b       839,7 MiB/s       845,6 MiB/s
    twofish-xts        256b       461,4 MiB/s       474,5 MiB/s
        aes-xts        512b      3237,6 MiB/s      3227,1 MiB/s
    serpent-xts        512b       854,9 MiB/s       834,6 MiB/s
    twofish-xts        512b       462,6 MiB/s       474,6 MiB/s
