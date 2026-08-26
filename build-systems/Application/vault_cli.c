#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

/* Definitions supplied by the cipher modules — signatures match the
 * caesar_cipher.h and xor_cipher.h headers in build-systems/makefile-project/Modules. */
extern void caesar_process(unsigned char *data, size_t length, int key, int encrypt);
extern void xor_process(unsigned char *data, size_t length, unsigned char key);

static void print_usage(void) {
    printf("Usage: ./vault_cli <encrypt|decrypt> <caesar|xor>  <key>\n");
    printf("Example: ./vault_cli encrypt xor secret.txt K\n");
}

int main(int argc, char *argv[]) {
    if (argc != 5) {
        print_usage();
        return EXIT_FAILURE;
    }

    const char *operation = argv[1];
    const char *algorithm = argv[2];
    const char *filepath  = argv[3];
    const char *key_str   = argv[4];

    /* 1. Open and read the input file in binary mode. */
    FILE *infile = fopen(filepath, "rb");
    if (!infile) {
        perror("[ERROR] Cannot open input file");
        return EXIT_FAILURE;
    }

    if (fseek(infile, 0, SEEK_END) != 0) {
        perror("[ERROR] fseek failed");
        fclose(infile);
        return EXIT_FAILURE;
    }
    long filesize = ftell(infile);
    if (filesize < 0) {
        perror("[ERROR] ftell failed");
        fclose(infile);
        return EXIT_FAILURE;
    }
    rewind(infile);

    /* Guard against zero-byte files: malloc(0) is implementation-defined. */
    unsigned char *buffer = NULL;
    size_t length = 0;
    if (filesize > 0) {
        length = (size_t)filesize;
        buffer = (unsigned char *)malloc(length);
        if (!buffer) {
            perror("[ERROR] malloc failed");
            fclose(infile);
            return EXIT_FAILURE;
        }
        if (fread(buffer, 1, length, infile) != length) {
            perror("[ERROR] fread failed");
            free(buffer);
            fclose(infile);
            return EXIT_FAILURE;
        }
    }
    fclose(infile);

    /* 2. Apply the requested algorithm. */
    int is_encrypt = (strcmp(operation, "encrypt") == 0);

    if (strcmp(algorithm, "caesar") == 0) {
        int key = atoi(key_str);
        caesar_process(buffer, length, key, is_encrypt);
    } else if (strcmp(algorithm, "xor") == 0) {
        /* Take the first character of the key but treat it as unsigned
         * so high-bit keys don't get sign-extended. */
        if (key_str[0] == '\0') {
            fprintf(stderr, "[ERROR] XOR key must not be empty\n");
            free(buffer);
            return EXIT_FAILURE;
        }
        unsigned char key = (unsigned char)key_str[0];
        xor_process(buffer, length, key);
    } else {
        printf("[ERROR] Unsupported algorithm: %s\n", algorithm);
        free(buffer);
        return EXIT_FAILURE;
    }

    /* 3. Choose an output path.
     *
     * If the input is foo.txt and we're encrypting -> foo.txt.enc
     * If the input is foo.txt.enc and we're decrypting -> foo.txt
     *
     * Strip a trailing .enc on decrypt so we don't produce foo.txt.enc.dec. */
    char out_filepath[512];
    if (is_encrypt) {
        snprintf(out_filepath, sizeof(out_filepath), "%s.enc", filepath);
    } else {
        size_t flen = strlen(filepath);
        const char *enc_suffix = ".enc";
        const size_t enc_suffix_len = strlen(enc_suffix);
        if (flen > enc_suffix_len &&
            strcmp(filepath + flen - enc_suffix_len, enc_suffix) == 0) {
            size_t out_len = flen - enc_suffix_len;
            if (out_len >= sizeof(out_filepath)) {
                fprintf(stderr, "[ERROR] Output path too long\n");
                free(buffer);
                return EXIT_FAILURE;
            }
            memcpy(out_filepath, filepath, out_len);
            out_filepath[out_len] = '\0';
        } else {
            snprintf(out_filepath, sizeof(out_filepath), "%s.dec", filepath);
        }
    }

    FILE *outfile = fopen(out_filepath, "wb");
    if (!outfile) {
        perror("[ERROR] Cannot create output file");
        free(buffer);
        return EXIT_FAILURE;
    }
    if (length > 0 && fwrite(buffer, 1, length, outfile) != length) {
        perror("[ERROR] fwrite failed");
        fclose(outfile);
        free(buffer);
        return EXIT_FAILURE;
    }
    fclose(outfile);
    free(buffer);

    /* 4. Lock down permissions — owner read/write only. */
    if (chmod(out_filepath, S_IRUSR | S_IWUSR) != 0) {
        perror("[WARNING] Failed to set strict file permissions");
    }

    printf("\n[SUCCESS] File processed successfully!\n");
    printf("Output File: %s\n", out_filepath);
    printf("Permissions: 0600 (Owner access only)\n");

    /* 5. Optionally shred the original on encrypt so plaintext
     *    doesn't linger on disk. */
    if (is_encrypt) {
        if (remove(filepath) == 0) {
            printf("Original file '%s' has been securely removed.\n", filepath);
        } else {
            perror("[WARNING] Failed to remove original file");
        }
    }

    return EXIT_SUCCESS;
}
