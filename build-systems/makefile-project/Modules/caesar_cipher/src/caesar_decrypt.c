/*
===================================================================================================
 Name        : caesar_decrypt.c
 Copyright   : Edges For Training
 Description : Caesar cipher decryption — legacy NUL-terminated helper.
===================================================================================================
*/
#include "caesar_cipher.h"

void caesar_decrypt(char *text, int key) {
    caesar_process((unsigned char *)text, (size_t)__builtin_strlen(text), key, 0);
}
