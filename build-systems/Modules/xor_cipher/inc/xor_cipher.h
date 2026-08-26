/*
===================================================================================================
 Name        : xor_cipher.h
 Copyright   : Edges For Training
 Description : Header file for xor cipher encryption and decryption functions.
===================================================================================================
*/
#ifndef XOR_CIPHER_H
#define XOR_CIPHER_H

#include <stddef.h>
#include <stdint.h>

/* Unified entry point: XOR is symmetric, so the same function encrypts
 * and decrypts. Operates on a binary buffer of `length` bytes. */
void xor_process(unsigned char *data, size_t length, unsigned char key);

/* Legacy text-only helpers. `key` is an unsigned char to avoid sign
 * extension when the high bit is set. */
void xor_encrypt(char *text, unsigned char key);
void xor_decrypt(char *text, unsigned char key);

#endif // XOR_CIPHER_H
