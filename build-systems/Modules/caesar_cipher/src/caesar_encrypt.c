/*
===================================================================================================
 Name        : caesar_encrypt.c
 Copyright   : Edges For Training
 Description : Caesar cipher helpers — provides both the legacy
               NUL-terminated string API and the unified binary-buffer
               `caesar_process` API used by vault_cli.
===================================================================================================
*/
#include "caesar_cipher.h"

void caesar_process(unsigned char *data, size_t length, int key, int encrypt) {
    /* Normalize key into [0, 26) once, so callers can pass any int. */
    int shift = ((key % 26) + 26) % 26;
    if (!encrypt) {
        shift = (26 - shift) % 26;
    }

    for (size_t i = 0; i < length; i++) {
        unsigned char c = data[i];
        if (c >= 'a' && c <= 'z') {
            data[i] = (unsigned char)((c - 'a' + shift) % 26 + 'a');
        } else if (c >= 'A' && c <= 'Z') {
            data[i] = (unsigned char)((c - 'A' + shift) % 26 + 'A');
        }
    }
}

void caesar_encrypt(char *text, int key) {
    /* Legacy wrapper — strlen is safe here because `text` is documented
     * as a NUL-terminated string. */
    caesar_process((unsigned char *)text, (size_t)__builtin_strlen(text), key, 1);
}
