#!bin/bash
# convert static libergo.a to shared libsigma.so  so we can use Ruby FFI Gem
gcc -c -fpic sigma.c -o sigma.o
gcc -shared -o libsigma.so sigma.o -Xlinker --whole-archive libergo.a -Xlinker --no-whole-archive
