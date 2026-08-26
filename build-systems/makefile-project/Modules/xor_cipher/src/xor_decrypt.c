/*
===================================================================================================
 Name        : xor_decrypt.c
 Copyright   : Edges For Training
 Description : XOR cipher decryption — legacy NUL-terminated helper.
===================================================================================================
*/
#include "xor_cipher.h"

void xor_decrypt(char *text, unsigned char key) {
    xor_process((unsigned char *)text, (size_t)__builtin_strlen(text), key);
}
