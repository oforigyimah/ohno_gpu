#define SHA256_HASH_SIZE 32
#define SHA256_STRING_HASH_SIZE ((SHA256_HASH_SIZE * 2) + 1)

#define SHA512_HASH_SIZE 64
#define SHA512_STRING_HASH_SIZE ((SHA512_HASH_SIZE * 2) + 1)




typedef unsigned char _uint8;
typedef unsigned int  _uint32;
typedef unsigned long long _uint64;
typedef _uint32 SHA265_word_t;
typedef _uint64 SHA512_word_t;



#define SHA256_WORD_SIZE sizeof(SHA265_word_t)
#define SHA256_WORD_SIZE_BITS (SHA256_WORD_SIZE * 8)

#define SHA512_WORD_SIZE sizeof(SHA512_word_t)
#define SHA512_WORD_SIZE_BITS (SHA512_WORD_SIZE * 8)



#define SHA256_BLOCK_SIZE (SHA256_WORD_SIZE * 16)
#define SHA256_BLOCK_SIZE_BITS (SHA256_BLOCK_SIZE * 8)

#define SHA256_TURNS 64

#define SHA256_SHR(a,b) ((a) >> (b))
#define SHA256_ROTR(a,b) (((a) >> (b)) | ((a) << (SHA256_WORD_SIZE_BITS-(b))))
#define SHA256_CH(x,y,z) (((x) & (y)) ^ (~(x) & (z)))
#define SHA256_MAJ(x,y,z) (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))

#define SHA256_EP0(x) (SHA256_ROTR(x,2) ^ SHA256_ROTR(x,13) ^ SHA256_ROTR(x,22))
#define SHA256_EP1(x) (SHA256_ROTR(x,6) ^ SHA256_ROTR(x,11) ^ SHA256_ROTR(x,25))
#define SHA256_SIG0(x) (SHA256_ROTR(x,7) ^ SHA256_ROTR(x,18) ^ SHA256_SHR(x,3))
#define SHA256_SIG1(x) (SHA256_ROTR(x,17) ^ SHA256_ROTR(x,19) ^ SHA256_SHR(x,10))



#define BLOCK_SIZE (SHA512_WORD_SIZE * 16)
#define BLOCK_SIZE_BITS (BLOCK_SIZE * 8)

#define SHA512_TURNS 80

#define SHA512_SHR(a,b) ((a) >> (b))
#define SHA512_ROTR(a,b) (((a) >> (b)) | ((a) << (SHA512_WORD_SIZE_BITS-(b))))
#define SHA512_CH(x,y,z) (((x) & (y)) ^ (~(x) & (z)))
#define SHA512_MAJ(x,y,z) (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))

#define SHA512_EP0(x) (SHA512_ROTR(x,28) ^ SHA512_ROTR(x,34) ^ SHA512_ROTR(x,39))
#define SHA512_EP1(x) (SHA512_ROTR(x,14) ^ SHA512_ROTR(x,18) ^ SHA512_ROTR(x,41))
#define SHA512_SIG0(x) (SHA512_ROTR(x,1) ^ SHA512_ROTR(x,8) ^ SHA512_SHR(x,7))
#define SHA512_SIG1(x) (SHA512_ROTR(x,19) ^ SHA512_ROTR(x,61) ^ SHA512_SHR(x,6))


void  *memset(void *b, int c, int len);


void sha256(const __generic void * const data, const size_t size, _uint8 hash[SHA256_HASH_SIZE]);
void sha256_compute(const __generic _uint8 data[], const size_t size, SHA265_word_t state[8]);


void sha512(const __generic void * const data, const size_t size, _uint8 hash[SHA512_HASH_SIZE]);
void sha512_compute(const __generic _uint8 data[], const size_t size, SHA512_word_t state[8]);



void sha256(const __generic void * const data, const size_t size, _uint8 hash[SHA256_HASH_SIZE]) {
	SHA265_word_t state[8] = {
		0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
	};
	unsigned int i, j;

	sha256_compute(data, size, state);

	for (i = 0; i < SHA256_WORD_SIZE; i++) {
		for (j = 0; j < SHA256_HASH_SIZE / SHA256_WORD_SIZE; j++) {
			hash[i + SHA256_WORD_SIZE * j] = state[j] >> (SHA256_WORD_SIZE_BITS - 8 - i * 8);
		}
	}
}


void sha512(const __generic void * const data, const size_t size, _uint8 hash[SHA512_HASH_SIZE]) {
	SHA512_word_t state[8] = {
		0x6a09e667f3bcc908, 0xbb67ae8584caa73b, 0x3c6ef372fe94f82b, 0xa54ff53a5f1d36f1,
		0x510e527fade682d1, 0x9b05688c2b3e6c1f, 0x1f83d9abfb41bd6b, 0x5be0cd19137e2179
	};
	unsigned int i, j;

	sha512_compute(data, size, state);

	for (i = 0; i < SHA512_WORD_SIZE; i++) {
		for (j = 0; j < SHA512_HASH_SIZE / SHA512_WORD_SIZE; j++) {
			hash[i + SHA512_WORD_SIZE * j] = state[j] >> (SHA512_WORD_SIZE_BITS - 8 - i * 8);
		}
	}
}




static const SHA265_word_t SHA256_CONSTANTS[SHA256_TURNS] = {
	0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
	0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
	0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
	0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
	0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
	0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
	0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
	0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
};

void sha256_compress(SHA265_word_t res[SHA256_BLOCK_SIZE], SHA265_word_t state[8]) {
	SHA265_word_t a, b, c, d, e, f, g, h, t1, t2;
	SHA265_word_t m[SHA256_TURNS] = {
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	};
	unsigned int i, j, k;

	for (i = 0, j = 0; i < 16; i++, j += SHA256_WORD_SIZE) {
		for (k = 0; k < SHA256_WORD_SIZE; k++) {
			m[i] |= (res[j + k] << (SHA256_WORD_SIZE_BITS - 8 - k * 8));
		}
	}
	for (; i < SHA256_TURNS; i++) {
		m[i] = SHA256_SIG1(m[i - 2]) + m[i - 7] + SHA256_SIG0(m[i - 15]) + m[i - 16];
	}

	a = state[0];
	b = state[1];
	c = state[2];
	d = state[3];
	e = state[4];
	f = state[5];
	g = state[6];
	h = state[7];

	for (i = 0; i < SHA256_TURNS; i++) {
		t1 = h + SHA256_EP1(e) + SHA256_CH(e, f, g) + SHA256_CONSTANTS[i] + m[i];
		t2 = SHA256_EP0(a) + SHA256_MAJ(a, b, c);
		h = g;
		g = f;
		f = e;
		e = d + t1;
		d = c;
		c = b;
		b = a;
		a = t1 + t2;
	}

	state[0] += a;
	state[1] += b;
	state[2] += c;
	state[3] += d;
	state[4] += e;
	state[5] += f;
	state[6] += g;
	state[7] += h;
}

void sha256_compute(const __generic _uint8 data[], const size_t size, SHA265_word_t state[8]) {
	SHA265_word_t datalength = 0;
	_uint64 bitlength = 0;
	SHA265_word_t result[SHA256_BLOCK_SIZE];
	unsigned int i;

	//compressing
	for (i = 0; i < size; i++) {
		result[datalength] = data[i];
		datalength++;
		if (datalength == SHA256_BLOCK_SIZE) {
			sha256_compress(result, state);
			bitlength += SHA256_BLOCK_SIZE_BITS;
			datalength = 0;
		}
	}

	i = datalength;

	//padding
	if (datalength < SHA256_BLOCK_SIZE - 8) {
		result[i++] = 0x80;
		while (i < SHA256_BLOCK_SIZE - 8) {
			result[i++] = 0;
		}
	} else {
		result[i++] = 0x80;
		while (i < SHA256_BLOCK_SIZE) {
			result[i++] = 0;
		}
		sha256_compress(result, state);
		memset(result, 0, SHA256_BLOCK_SIZE - 8);
	}

	//append
	bitlength += datalength * 8;
	for (i = 0; i < 8; i++) {
		result[SHA256_BLOCK_SIZE - 1 - i] = bitlength >> (i * 8);
	}
	sha256_compress(result, state);
}






static const SHA512_word_t SHA512_CONSTANTS[SHA512_TURNS] = {
	0x428a2f98d728ae22, 0x7137449123ef65cd, 0xb5c0fbcfec4d3b2f, 0xe9b5dba58189dbbc, 0x3956c25bf348b538,
	0x59f111f1b605d019, 0x923f82a4af194f9b, 0xab1c5ed5da6d8118, 0xd807aa98a3030242, 0x12835b0145706fbe,
	0x243185be4ee4b28c, 0x550c7dc3d5ffb4e2, 0x72be5d74f27b896f, 0x80deb1fe3b1696b1, 0x9bdc06a725c71235,
	0xc19bf174cf692694, 0xe49b69c19ef14ad2, 0xefbe4786384f25e3, 0x0fc19dc68b8cd5b5, 0x240ca1cc77ac9c65,
	0x2de92c6f592b0275, 0x4a7484aa6ea6e483, 0x5cb0a9dcbd41fbd4, 0x76f988da831153b5, 0x983e5152ee66dfab,
	0xa831c66d2db43210, 0xb00327c898fb213f, 0xbf597fc7beef0ee4, 0xc6e00bf33da88fc2, 0xd5a79147930aa725,
	0x06ca6351e003826f, 0x142929670a0e6e70, 0x27b70a8546d22ffc, 0x2e1b21385c26c926, 0x4d2c6dfc5ac42aed,
	0x53380d139d95b3df, 0x650a73548baf63de, 0x766a0abb3c77b2a8, 0x81c2c92e47edaee6, 0x92722c851482353b,
	0xa2bfe8a14cf10364, 0xa81a664bbc423001, 0xc24b8b70d0f89791, 0xc76c51a30654be30, 0xd192e819d6ef5218,
	0xd69906245565a910, 0xf40e35855771202a, 0x106aa07032bbd1b8, 0x19a4c116b8d2d0c8, 0x1e376c085141ab53,
	0x2748774cdf8eeb99, 0x34b0bcb5e19b48a8, 0x391c0cb3c5c95a63, 0x4ed8aa4ae3418acb, 0x5b9cca4f7763e373,
	0x682e6ff3d6b2b8a3, 0x748f82ee5defb2fc, 0x78a5636f43172f60, 0x84c87814a1f0ab72, 0x8cc702081a6439ec,
	0x90befffa23631e28, 0xa4506cebde82bde9, 0xbef9a3f7b2c67915, 0xc67178f2e372532b, 0xca273eceea26619c,
	0xd186b8c721c0c207, 0xeada7dd6cde0eb1e, 0xf57d4f7fee6ed178, 0x06f067aa72176fba, 0x0a637dc5a2c898a6,
	0x113f9804bef90dae, 0x1b710b35131c471b, 0x28db77f523047d84, 0x32caab7b40c72493, 0x3c9ebe0a15c9bebc,
	0x431d67c49c100d4c, 0x4cc5d4becb3e42b6, 0x597f299cfc657e2a, 0x5fcb6fab3ad6faec, 0x6c44198c4a475817
};

void sha512_compress(SHA512_word_t res[BLOCK_SIZE], SHA512_word_t state[8]) {
	SHA512_word_t a, b, c, d, e, f, g, h, t1, t2;
	SHA512_word_t m[SHA512_TURNS] = {
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	};
	unsigned int i, j, k;

	for (i = 0, j = 0; i < 16; i++, j += SHA512_WORD_SIZE) {
		for (k = 0; k < SHA512_WORD_SIZE; k++) {
			m[i] |= (res[j + k] << (SHA512_WORD_SIZE_BITS - 8 - k * 8));
		}
	}
	for (; i < SHA512_TURNS; i++) {
		m[i] = SHA512_SIG1(m[i - 2]) + m[i - 7] + SHA512_SIG0(m[i - 15]) + m[i - 16];
	}

	a = state[0];
	b = state[1];
	c = state[2];
	d = state[3];
	e = state[4];
	f = state[5];
	g = state[6];
	h = state[7];

	for (i = 0; i < SHA512_TURNS; i++) {
		t1 = h + SHA512_EP1(e) + SHA512_CH(e, f, g) + SHA512_CONSTANTS[i] + m[i];
		t2 = SHA512_EP0(a) + SHA512_MAJ(a, b, c);
		h = g;
		g = f;
		f = e;
		e = d + t1;
		d = c;
		c = b;
		b = a;
		a = t1 + t2;
	}

	state[0] += a;
	state[1] += b;
	state[2] += c;
	state[3] += d;
	state[4] += e;
	state[5] += f;
	state[6] += g;
	state[7] += h;
}

void sha512_compute(const __generic _uint8 data[], const size_t size, SHA512_word_t state[8]) {
	SHA512_word_t datalength = 0;
	_uint64 bitlength = 0;
	SHA512_word_t result[BLOCK_SIZE];
	unsigned int i;

	//compressing
	for (i = 0; i < size; i++) {
		result[datalength] = data[i];
		datalength++;
		if (datalength == BLOCK_SIZE) {
			sha512_compress(result, state);
			bitlength += BLOCK_SIZE_BITS;
			datalength = 0;
		}
	}

	i = datalength;

	//padding
	if (datalength < BLOCK_SIZE - 8) {
		result[i++] = 0x80;
		while (i < BLOCK_SIZE - 8) {
			result[i++] = 0;
		}
	} else {
		result[i++] = 0x80;
		while (i < BLOCK_SIZE) {
			result[i++] = 0;
		}
		sha512_compress(result, state);
		memset(result, 0, BLOCK_SIZE - 8);
	}

	//append
	bitlength += datalength * 8;
	for (i = 0; i < 8; i++) {
		result[BLOCK_SIZE - 1 - i] = bitlength >> (i * 8);
	}
	sha512_compress(result, state);
}

/************************************ END OF SHA2 *************************************************/


/************************************ HELPER FUNCTIONS ********************************************/


void hex_to_byte_array(const char* hex_string, _uint8* byte_array, int hex_string_length) {
    for (int _idx = 0; _idx * 2 < hex_string_length; _idx++) {
        char c1 = hex_string[_idx * 2];
        char c2 = hex_string[_idx * 2 + 1];

        _uint8 b1 = (c1 <= '9') ? (c1 - '0') : (c1 - 'a' + 10);
        _uint8 b2 = (c2 <= '9') ? (c2 - '0') : (c2 - 'a' + 10);

        byte_array[_idx] = (b1 << 4) | b2;
    }
}

void byte_array_to_hex(const _uint8* byte_array, char* hex_string, int byte_array_length) {
    for (int idx_ = 0; idx_ < byte_array_length; idx_++) {
        _uint8 b = byte_array[idx_];
        _uint8 b1 = (b >> 4) & 0x0f;
        _uint8 b2 = b & 0x0f;

        hex_string[idx_ * 2] = (b1 < 10) ? (b1 + '0') : (b1 - 10 + 'a');
        hex_string[idx_ * 2 + 1] = (b2 < 10) ? (b2 + '0') : (b2 - 10 + 'a');
    }
    hex_string[byte_array_length * 2] = '\0';
}

int cmp_byte_array(const _uint8* byte_array1, const _uint8* byte_array2, int byte_array_length) {
    for (int idx_ = 0; idx_ < byte_array_length; idx_++) {
        if (byte_array1[idx_] != byte_array2[idx_]) {
            return 0;
        }
    }
    return 1;
}

void strcpy(char *dest, const char *src)
{
    while (*src != '\0')
    {
        *dest = *src;
        src++;
        dest++;
    }
    *dest = '\0';
}


void slice(const char* str, char* buffer, int start, int end) {
    int j = 0;
    for (int i = start; i < end; i++) {
        buffer[j++] = str[i];
    }
    buffer[j] = '\0';
}

//function to reverse a string
void reverse(__generic char str[], int length)
{
    int start;
    int end = length -1;
    for(start = 0; start < end; ++start, --end)
    {
        const char ch = str[start];
        str[start] = str[end];
        str[end] = ch;
    }
}

char* _itoa(int num, char* str, int base)
{
    int i = 0;
    char isNegNum = 0;
    /*Handle 0 explicitly,
      otherwise empty string is printed for 0 */
    if (num == 0)
    {
        str[i++] = '0';
        str[i] = '\0';
    }
    else
    {
        // In library itoa function -ve numbers handled only with
        // base 10. SO here we are also following same concept
        if ((num < 0) && (base == 10))
        {
            isNegNum = 1;
            num = -num; // make num positive
        }
        // Process individual digits
        do
        {
            const int rem = (num % base);
            str[i++] = (rem > 9)? ((rem-10) + 'a') : (rem + '0');
            num = num/base;
        }
        while (num != 0);
        // If number is negative, append '-'
        if (isNegNum)
        {
            str[i++] = '-';
        }
        // Append string terminator
        str[i] = '\0';
        // Reverse the string
        reverse(str, i);
    }
    return str;
}

int _strlen(char *s)
{
    int len = 0;
    while (*(s + len) != '\0')
    {
        len++;
    }
    return (len);
}

void  *memset(void *b, int c, int len)
{
    unsigned char *p = b;
    while(len > 0)
    {
        *p = c;
        p++;
        len--;
    }
    return(b);
}




/*********************************** END OF HElPER FUNCTIONS ***************************************/






/************************************* KERNEL ******************************************************/

__kernel void calSha256(
        __global const char *hashes,
        __global const char *games,
        __global char *passed_hash,
        __global const long unsigned int start[],
        const int len
)
{
    int idx = get_global_id(0);
    char num[512];
    _uint8 sha512_byte_array[SHA512_HASH_SIZE];
    _uint8 sha256_byte_array[SHA256_HASH_SIZE];
    _uint8 hash_byte_array[SHA256_HASH_SIZE];
    char sha512_hex_string[SHA512_STRING_HASH_SIZE];
    char sha256_hex_string[SHA256_STRING_HASH_SIZE];
    char sliced_hex_string[SHA256_STRING_HASH_SIZE];
	char hash[SHA256_STRING_HASH_SIZE];
    char _hashes[30][64];
    char _games[30][32];
    _uint8 _hashes_byte_array[30][32];
    int boo;

    for (int q = 0; q < 2; q++) {
        if (q) _itoa(idx + start[0], num, 10);
        else _itoa(-((long signed int) (idx + start[0])), num, 10);
        sha512(num, _strlen(num), sha512_byte_array);
        byte_array_to_hex(sha512_byte_array, sha512_hex_string, SHA512_HASH_SIZE);

        for (int i = 0; i < len; i++) {
            slice(hashes, _hashes[i], i * 64, (i + 1) * 64);
            hex_to_byte_array(_hashes[i], _hashes_byte_array[i], 64);
        }
        for (int i = 0; i < len; i++) {
            slice(games, _games[i], i * 32, (i + 1) * 32);
        }


        for (int i = 0; i < 64; i++) {
            slice(sha512_hex_string, sliced_hex_string, i, 64 + i);
            strcpy(hash, sliced_hex_string);


            for (int count = 0; count < 10000; count++) {

                sha256(hash, _strlen(sliced_hex_string), sha256_byte_array);
                byte_array_to_hex(sha256_byte_array, hash, SHA256_HASH_SIZE);

                for (int w = 0; w < len; w++) {
                    boo = cmp_byte_array(_hashes_byte_array[w], sha256_byte_array, SHA256_HASH_SIZE);
                    if (boo) {
                        strcpy(passed_hash, sliced_hex_string);
                        printf("passed hash is %s\n", passed_hash);
                        printf("game is %s\n", _games[w]);
                        printf("idx is %d\n", idx);
                        return;
                    }
                }
            }


        }
    }

}

/********************************* END OF KERNEL ***************************************************/