/*
 * Copyright (c) 2013 AMD
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met: redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer;
 * redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution;
 * neither the name of the copyright holders nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERHCCES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * Author:  Maohua Zhu
 *          Junli Gu
 */


// OpenCL RBM
typedef float floatType;

typedef uint uint32_t;

struct r123array4x32 {	uint32_t v[4]; };

enum r123_enum_threefry32x4 
{
	R_32x4_0_0 = 10, R_32x4_0_1 = 26,
	R_32x4_1_0 = 11, R_32x4_1_1 = 21,
	R_32x4_2_0 = 13, R_32x4_2_1 = 27,
	R_32x4_3_0 = 23, R_32x4_3_1 =  5,
	R_32x4_4_0 =  6, R_32x4_4_1 = 20,
	R_32x4_5_0 = 17, R_32x4_5_1 = 11,
	R_32x4_6_0 = 25, R_32x4_6_1 = 10,
	R_32x4_7_0 = 18, R_32x4_7_1 = 20
};

inline uint32_t	RotL_32(uint32_t x, unsigned int N)__attribute__((always_inline));
inline uint32_t RotL_32(uint32_t x, unsigned int N)
{
	return (x << (N & 31)) | (x >> ((32 - N) & 31));
}

typedef struct r123array4x32 threefry4x32_ctr_t;
typedef struct r123array4x32 threefry4x32_key_t;
typedef struct r123array4x32 threefry4x32_ukey_t;

inline threefry4x32_ctr_t threefry4x32_R(unsigned int Nrounds, threefry4x32_ctr_t in, threefry4x32_key_t k)__attribute__((always_inline));
inline threefry4x32_ctr_t threefry4x32_R(unsigned int Nrounds, threefry4x32_ctr_t in, threefry4x32_key_t k)
{
	threefry4x32_ctr_t	X;
	uint32_t			ks[4 + 1];
	int					i;
	ks[4] = 0x1BD11BDA;
	for (i = 0; i < 4; i++) 
	{
		ks[i] = k.v[i];
		X.v[i] = in.v[i];
		ks[4] ^= k.v[i];
	} 
	X.v[0] += ks[0];
	X.v[1] += ks[1];
	X.v[2] += ks[2];
	X.v[3] += ks[3];
	if (Nrounds > 0) 
	{
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_0_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_0_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 1) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_1_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_1_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 2) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_2_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_2_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 3) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_3_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_3_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 3) {
		X.v[0] += ks[1];
		X.v[1] += ks[2];
		X.v[2] += ks[3];
		X.v[3] += ks[4];
		X.v[4 - 1] += 1;
	} if (Nrounds > 4) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_4_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_4_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 5) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_5_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_5_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 6) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_6_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_6_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 7) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_7_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_7_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 7) {
		X.v[0] += ks[2];
		X.v[1] += ks[3];
		X.v[2] += ks[4];
		X.v[3] += ks[0];
		X.v[4 - 1] += 2;
	} if (Nrounds > 8) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_0_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_0_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 9) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_1_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_1_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 10) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_2_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_2_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 11) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_3_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_3_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 11) {
		X.v[0] += ks[3];
		X.v[1] += ks[4];
		X.v[2] += ks[0];
		X.v[3] += ks[1];
		X.v[4 - 1] += 3;
	} if (Nrounds > 12) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_4_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_4_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 13) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_5_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_5_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 14) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_6_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_6_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 15) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_7_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_7_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 15) {
		X.v[0] += ks[4];
		X.v[1] += ks[0];
		X.v[2] += ks[1];
		X.v[3] += ks[2];
		X.v[4 - 1] += 4;
	} if (Nrounds > 16) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_0_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_0_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 17) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_1_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_1_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 18) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_2_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_2_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 19) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_3_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_3_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 19) {
		X.v[0] += ks[0];
		X.v[1] += ks[1];
		X.v[2] += ks[2];
		X.v[3] += ks[3];
		X.v[4 - 1] += 5;
	} if (Nrounds > 20) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_4_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_4_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 21) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_5_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_5_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 22) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_6_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_6_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 23) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_7_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_7_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 23) {
		X.v[0] += ks[1];
		X.v[1] += ks[2];
		X.v[2] += ks[3];
		X.v[3] += ks[4];
		X.v[4 - 1] += 6;
	} if (Nrounds > 24) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_0_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_0_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 25) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_1_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_1_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 26) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_2_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_2_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 27) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_3_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_3_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 27) {
		X.v[0] += ks[2];
		X.v[1] += ks[3];
		X.v[2] += ks[4];
		X.v[3] += ks[0];
		X.v[4 - 1] += 7;
	} if (Nrounds > 28) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_4_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_4_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 29) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_5_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_5_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 30) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_6_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_6_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 31) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_7_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_7_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 31) {
		X.v[0] += ks[3];
		X.v[1] += ks[4];
		X.v[2] += ks[0];
		X.v[3] += ks[1];
		X.v[4 - 1] += 8;
	} if (Nrounds > 32) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_0_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_0_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 33) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_1_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_1_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 34) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_2_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_2_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 35) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_3_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_3_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 35) {
		X.v[0] += ks[4];
		X.v[1] += ks[0];
		X.v[2] += ks[1];
		X.v[3] += ks[2];
		X.v[4 - 1] += 9;
	} if (Nrounds > 36) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_4_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_4_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 37) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_5_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_5_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 38) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_6_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_6_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 39) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_7_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_7_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 39) {
		X.v[0] += ks[0];
		X.v[1] += ks[1];
		X.v[2] += ks[2];
		X.v[3] += ks[3];
		X.v[4 - 1] += 10;
	} if (Nrounds > 40) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_0_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_0_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 41) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_1_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_1_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 42) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_2_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_2_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 43) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_3_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_3_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 43) {
		X.v[0] += ks[1];
		X.v[1] += ks[2];
		X.v[2] += ks[3];
		X.v[3] += ks[4];
		X.v[4 - 1] += 11;
	} if (Nrounds > 44) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_4_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_4_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 45) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_5_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_5_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 46) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_6_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_6_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 47) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_7_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_7_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 47) {
		X.v[0] += ks[2];
		X.v[1] += ks[3];
		X.v[2] += ks[4];
		X.v[3] += ks[0];
		X.v[4 - 1] += 12;
	} if (Nrounds > 48) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_0_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_0_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 49) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_1_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_1_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 50) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_2_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_2_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 51) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_3_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_3_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 51) {
		X.v[0] += ks[3];
		X.v[1] += ks[4];
		X.v[2] += ks[0];
		X.v[3] += ks[1];
		X.v[4 - 1] += 13;
	} if (Nrounds > 52) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_4_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_4_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 53) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_5_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_5_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 54) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_6_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_6_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 55) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_7_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_7_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 55) {
		X.v[0] += ks[4];
		X.v[1] += ks[0];
		X.v[2] += ks[1];
		X.v[3] += ks[2];
		X.v[4 - 1] += 14;
	} if (Nrounds > 56) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_0_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_0_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 57) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_1_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_1_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 58) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_2_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_2_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 59) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_3_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_3_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 59) {
		X.v[0] += ks[0];
		X.v[1] += ks[1];
		X.v[2] += ks[2];
		X.v[3] += ks[3];
		X.v[4 - 1] += 15;
	} if (Nrounds > 60) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_4_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_4_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 61) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_5_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_5_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 62) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_6_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_6_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 63) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_7_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_7_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 63) {
		X.v[0] += ks[1];
		X.v[1] += ks[2];
		X.v[2] += ks[3];
		X.v[3] += ks[4];
		X.v[4 - 1] += 16;
	} if (Nrounds > 64) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_0_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_0_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 65) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_1_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_1_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 66) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_2_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_2_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 67) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_3_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_3_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 67) {
		X.v[0] += ks[2];
		X.v[1] += ks[3];
		X.v[2] += ks[4];
		X.v[3] += ks[0];
		X.v[4 - 1] += 17;
	} if (Nrounds > 68) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_4_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_4_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 69) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_5_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_5_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 70) {
		X.v[0] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_6_0);
		X.v[1] ^= X.v[0];
		X.v[2] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_6_1);
		X.v[3] ^= X.v[2];
	} if (Nrounds > 71) {
		X.v[0] += X.v[3];
		X.v[3] = RotL_32(X.v[3], R_32x4_7_0);
		X.v[3] ^= X.v[0];
		X.v[2] += X.v[1];
		X.v[1] = RotL_32(X.v[1], R_32x4_7_1);
		X.v[1] ^= X.v[2];
	} if (Nrounds > 71) {
		X.v[0] += ks[3];
		X.v[1] += ks[4];
		X.v[2] += ks[0];
		X.v[3] += ks[1];
		X.v[4 - 1] += 18;
	} 
	return X;
} 


__kernel void PRNG_threefry4x32(
	__global float4 *randomnumber, 
	threefry4x32_ctr_t ctr_i,
	float inf,
	float sup,
	uint nrounds,
	uint numrandom
){
	size_t	gdx = get_global_id(0);

	uint maxUint = 0;
	maxUint--;
	float r = (float)maxUint;

	threefry4x32_ctr_t	ctr = ctr_i; 
	threefry4x32_ukey_t ukey;

	ukey.v[0] = ukey.v[1] = ukey.v[2] = ukey.v[3] = gdx;

	threefry4x32_ctr_t  random4;

	if ( gdx < numrandom )
	{
		random4 = threefry4x32_R(nrounds, ctr, ukey);
		float4 frnd;
		frnd.x = (((float)random4.v[0]) / r) * (sup - inf) + inf;
		frnd.y = (((float)random4.v[1]) / r) * (sup - inf) + inf;
		frnd.z = (((float)random4.v[2]) / r) * (sup - inf) + inf;
		frnd.w = (((float)random4.v[3]) / r) * (sup - inf) + inf;
		randomnumber[gdx] = frnd;
	}
}


__kernel void PRNGn_threefry4x32(
	__global float4 *randomnumber, 
	threefry4x32_ctr_t ctr_i,
	float E,
	float V,
	uint nrounds,
	uint numrandom
){
	size_t	gdx = get_global_id(0);

	uint maxUint = 0;
	maxUint--;
	float r = (float)maxUint;

	threefry4x32_ctr_t	ctr = ctr_i; 
	threefry4x32_ukey_t ukey1, ukey2;

	ukey1.v[0] = ukey2.v[1] = ukey1.v[2] = ukey2.v[3] = gdx;
	ukey2.v[0] = ukey1.v[1] = ukey2.v[2] = ukey1.v[3] = 0;

	threefry4x32_ctr_t  random1, random2;

	if ( gdx < numrandom )
	{
		random1 = threefry4x32_R(nrounds, ctr, ukey1);
		random2 = threefry4x32_R(nrounds, ctr, ukey2);
		float4 frnd1;

		float r1 = (((float)random1.v[0]) / r);          // generate a random sequence of uniform distribution
		float r2 = (((float)random2.v[0]) / r);
		float r3 = (((float)random1.v[1]) / r);
		float r4 = (((float)random2.v[1]) / r);
		float r5 = (((float)random1.v[2]) / r);
		float r6 = (((float)random2.v[2]) / r);
		float r7 = (((float)random1.v[3]) / r);
		float r8 = (((float)random2.v[3]) / r);

		if(r2 == 0 || r4 == 0 || r6 == 0 || r8 == 0){
			r2 += 0.0001;
			r4 += 0.0001;
			r6 += 0.0001;
			r8 += 0.0001;
		}

		frnd1.x = cos(2*M_PI*r1)*sqrt(-2.0*log(r2)) * V + E;     // return a pseudo sequence of normal distribution using two above uniform noise data
		//frnd2.x = sin(2*M_PI*r1)*sqrt(-2.0*log(r2));      // return the quadrature counterpart of the foregoing pseudo normal distribution sequence
		frnd1.y = cos(2*M_PI*r3)*sqrt(-2.0*log(r4)) * V + E;     // return a pseudo sequence of normal distribution using two above uniform noise data
		//frnd2.y = sin(2*M_PI*r3)*sqrt(-2.0*log(r4));      // return the quadrature counterpart of the foregoing pseudo normal distribution sequence
		frnd1.z = cos(2*M_PI*r5)*sqrt(-2.0*log(r6)) * V + E;     // return a pseudo sequence of normal distribution using two above uniform noise data
		//frnd2.z = sin(2*M_PI*r5)*sqrt(-2.0*log(r6));      // return the quadrature counterpart of the foregoing pseudo normal distribution sequence
		frnd1.w = cos(2*M_PI*r7)*sqrt(-2.0*log(r8)) * V + E;     // return a pseudo sequence of normal distribution using two above uniform noise data
		//frnd2.w = sin(2*M_PI*r7)*sqrt(-2.0*log(r8));      // return the quadrature counterpart of the foregoing pseudo normal distribution sequence

		randomnumber[gdx] = frnd1;
	}
}


__kernel void reset(
	__global floatType* a,
	unsigned int n
	){
	unsigned int gid = get_global_id(0);
	if(gid < n){
		a[gid] = 0.0;
	}
}

__kernel void addBias(
	__global floatType* prob,
	__global floatType* bias,
	unsigned int layerSize,
	unsigned int nVectorPerBatch
	){
	unsigned int index = get_global_id(0);
	unsigned int feature = index % layerSize;
	if(index < layerSize * nVectorPerBatch){
		prob[index] = bias[feature];
	}
	return;
}

__kernel void addBias_no_reset(
	__global floatType* prob,
	__global floatType* bias,
	unsigned int layerSize,
	unsigned int nVectorPerBatch
	){
	unsigned int index = get_global_id(0);
	unsigned int feature = index % layerSize;
	if(index < layerSize * nVectorPerBatch){
		prob[index] += bias[feature];
	}
	return;
}

__kernel void sumBatch(
	__global floatType* prob,
	__global floatType* bias,
	unsigned int layerSize,
	unsigned int nVectorPerBatch
	){
	unsigned int feature = get_global_id(0);
	if(feature < layerSize){
		floatType sum = 0.0;
		for(int index = 0; index < nVectorPerBatch; index++){
			sum += prob[index * layerSize + feature];
		}
		bias[feature] = sum;
	}
	return;
}

__kernel void sigmoid(
	__global floatType* a,
	unsigned int n
	){
	unsigned int index = get_global_id(0);
	if(index < n){
		a[index] = 1 / (1 + exp(- a[index]));
	}
	return;
}

__kernel void squareError(
	__global floatType* a,
	__global floatType* b,
	__global floatType* c,
	unsigned int n
	){
	unsigned int gid = get_global_id(0);
	if(gid < n){
		c[gid] += (a[gid] - b[gid]) * (a[gid] - b[gid]);
	}
}

__kernel void add(
	__global floatType* a,
	__global floatType* b,
	unsigned int n
	){
	unsigned int index = get_global_id(0);
	if(index < n){
		a[index] += b[index];
	}
	return;
}

__kernel void getStates(
	__global floatType* states,
	__global floatType* prob,
	unsigned int n
	){
	unsigned int index = get_global_id(0);
	if(index < n){
		states[index] = (prob[index] > states[index]) ? 1.0 : 0.0;
	}
	return;
}

__kernel void rounding(
	__global floatType* states,
	__global floatType* prob,
	unsigned int n
	){
	unsigned int gdx = get_global_id(0);
	if(gdx < n){
		states[gdx] = (prob[gdx] > 0.5) ? 1.0 : 0.0;
	}
	return;

}

__kernel void updateWeights(
	__global floatType* weights,
	__global floatType* delta_weights,
	__global floatType* posProds,
	__global floatType* negProds,
	floatType momentum,
	floatType eps_w,
	floatType weightCost,
	unsigned int nVectorPerBatch
	){
		unsigned int index = get_global_id(0);
		delta_weights[index] = momentum * delta_weights[index] + eps_w * ((posProds[index] - negProds[index]) / nVectorPerBatch - weightCost * weights[index]);
		weights[index] += delta_weights[index];
		return;
}

__kernel void updateBias(
	__global floatType* bias,
	__global floatType* delta_bias,
	__global floatType* posAct,
	__global floatType* negAct,
	floatType momentum,
	floatType eps_b,
	unsigned int nVectorPerBatch 
	){
		unsigned int index = get_global_id(0);
		delta_bias[index] = momentum * delta_bias[index] + (eps_b / nVectorPerBatch) * (posAct[index] - negAct[index]);
		bias[index] += delta_bias[index];
		return;
}

__kernel void subtract(
	__global floatType* a,
	__global floatType* b,
	__global floatType* c,
	unsigned int n
	){
	unsigned int gdx = get_global_id(0);
	if(gdx < n){
		a[gdx] = b[gdx] - c[gdx];
	}
}

__kernel void deriv(
	__global floatType* err,
	__global floatType* act,
	unsigned int n
	){
	unsigned int gdx = get_global_id(0);
	if(gdx < n){
		err[gdx] *= (1 - act[gdx]) * act[gdx];
	}
}

__kernel void update(
	__global floatType* weight,
	__global floatType* delta_weight,
	__global floatType* bias,
	__global floatType* delta_bias,
	floatType eps_w,
	floatType eps_b,
	unsigned int nBottomLayerSize,
	unsigned int nUpperLayerSize
){
	unsigned int gdx = get_global_id(0);

	if(gdx < nBottomLayerSize * nUpperLayerSize)
	{
		weight[gdx] -= eps_w * delta_weight[gdx];
	}

	if(gdx < nUpperLayerSize)
	{
		bias[gdx] -= eps_b * delta_bias[gdx];
	}

	return;	
}


