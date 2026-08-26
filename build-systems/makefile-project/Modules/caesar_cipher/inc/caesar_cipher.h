/*
===================================================================================================
 Name        : caesar_cipher.h
 Copyright   : Edges For Training
 Description : Header file for Caesar cipher encryption and decryption functions.
===================================================================================================
*/
#ifndef CAESAR_H
#define CAESAR_H

#include <stddef.h>

/* Unified entry point: encrypt=1 to encrypt, encrypt=0 to decrypt.
 * Operates on a binary buffer of `length` bytes so it works for both
 * text and arbitrary file content (matches the rest of the vault). */
void caesar_process(unsigned char *data, size_t length, int key, int encrypt);

/* Legacy text-only helpers kept for compatibility with the
 * original Edges For Training examples. They treat the input as a
 * NUL-terminated string and only touch ASCII letters. */
void caesar_encrypt(char *text, int key);
void caesar_decrypt(char *text, int key);

#endif // CAESAR_H
