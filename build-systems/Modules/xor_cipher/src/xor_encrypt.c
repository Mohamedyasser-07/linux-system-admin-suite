/*
===================================================================================================
 Name        : xor_encrypt.c
 Copyright   : Edges For Training
 Description : XOR cipher — provides the unified binary buffer
               `xor_process` API used by vault_cli and the legacy
               NUL-terminated helper.
===================================================================================================
*/
#include "xor_cipher.h"

void xor_process(unsigned char *data, size_t length, unsigned char key) {
    for (size_t i = 0; i < length; i++) {
        data[i] ^= key;
    }
}

void xor_encrypt(char *text, unsigned char key) {
    xor_process((unsigned char *)text, (size_t)__builtin_strlen(text), key);
}
