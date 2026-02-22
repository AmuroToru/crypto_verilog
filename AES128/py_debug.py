#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
AES-128 调试工具
显示每一轮的：
- 轮密钥 (Round Key)
- 加密中间值 (State after each operation)
"""

class AES128_Debug:
    def __init__(self, key_hex, plaintext_hex):
        """
        初始化AES-128
        key_hex: 128位密钥的十六进制字符串 (32字符)
        plaintext_hex: 128位明文的十六进制字符串 (32字符)
        """
        # S-box (用于SubBytes)
        self.s_box = [
            0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
            0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
            0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
            0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
            0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
            0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
            0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
            0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
            0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
            0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
            0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
            0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
            0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
            0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
            0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
            0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
        ]
        
        # 轮常数 Rcon (用于密钥扩展)
        self.rcon = [
            0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36
        ]
        
        # 输入格式转换
        self.key = bytes.fromhex(key_hex)
        self.plaintext = bytes.fromhex(plaintext_hex)
        
        # 存储所有轮密钥
        self.round_keys = []
        
        # 存储每一轮的中间状态
        self.round_states = []
        
        print("=" * 70)
        print("AES-128 加密调试工具")
        print("=" * 70)
        print(f"密钥: {key_hex}")
        print(f"明文: {plaintext_hex}")
        print("=" * 70)

    def print_state(self, state, title, show_hex=True):
        """打印4x4状态矩阵"""
        print(f"\n{title}:")
        if show_hex:
            for i in range(4):
                row = [f"{state[i][j]:02x}" for j in range(4)]
                print(f"  [{i}] " + " ".join(row))
        else:
            for i in range(4):
                print(f"  [{i}] " + " ".join([f"{x:3d}" for x in state[i]]))

    def bytes_to_state(self, data):
        """将16字节数据转换为4x4状态矩阵 (列主序)"""
        state = [[0 for _ in range(4)] for _ in range(4)]
        for i in range(4):
            for j in range(4):
                state[j][i] = data[i*4 + j]
        return state

    def state_to_bytes(self, state):
        """将4x4状态矩阵转换为16字节数据"""
        result = bytearray(16)
        for i in range(4):
            for j in range(4):
                result[i*4 + j] = state[j][i]
        return bytes(result)

    def sub_bytes(self, state):
        """字节替换"""
        result = [[0 for _ in range(4)] for _ in range(4)]
        for i in range(4):
            for j in range(4):
                result[i][j] = self.s_box[state[i][j]]
        return result

    def shift_rows(self, state):
        """行移位"""
        result = [[0 for _ in range(4)] for _ in range(4)]
        for i in range(4):
            for j in range(4):
                result[i][j] = state[i][(j + i) % 4]
        return result

    def mix_columns(self, state):
        """列混合"""
        def galois_mul(a, b):
            """GF(2^8)上的乘法"""
            p = 0
            for _ in range(8):
                if b & 1:
                    p ^= a
                carry = a & 0x80
                a <<= 1
                if carry:
                    a ^= 0x1b
                b >>= 1
            return p & 0xff

        result = [[0 for _ in range(4)] for _ in range(4)]
        for c in range(4):
            result[0][c] = galois_mul(0x02, state[0][c]) ^ \
                           galois_mul(0x03, state[1][c]) ^ \
                           state[2][c] ^ state[3][c]
            result[1][c] = state[0][c] ^ \
                           galois_mul(0x02, state[1][c]) ^ \
                           galois_mul(0x03, state[2][c]) ^ \
                           state[3][c]
            result[2][c] = state[0][c] ^ state[1][c] ^ \
                           galois_mul(0x02, state[2][c]) ^ \
                           galois_mul(0x03, state[3][c])
            result[3][c] = galois_mul(0x03, state[0][c]) ^ \
                           state[1][c] ^ state[2][c] ^ \
                           galois_mul(0x02, state[3][c])
        return result

    def add_round_key(self, state, round_key):
        """轮密钥加"""
        result = [[0 for _ in range(4)] for _ in range(4)]
        key_state = self.bytes_to_state(round_key)
        for i in range(4):
            for j in range(4):
                result[i][j] = state[i][j] ^ key_state[i][j]
        return result

    def key_expansion(self):
        """密钥扩展 - 生成10轮密钥"""
        print("\n" + "=" * 70)
        print("密钥扩展过程")
        print("=" * 70)
        
        # 初始密钥作为第0轮密钥
        self.round_keys = [self.key]
        print(f"Round 0 Key: {self.key.hex()}")
        
        for round_num in range(1, 11):
            prev_key = self.round_keys[-1]
            new_key = bytearray(16)
            
            # 前3个字直接复制
            for i in range(4):
                new_key[i*4:(i+1)*4] = prev_key[i*4:(i+1)*4]
            
            # 生成最后一个字（需要特殊处理）
            temp = prev_key[12:16]  # 最后一个字
            
            # RotWord
            temp = temp[1:] + temp[:1]
            
            # SubWord
            temp = bytes([self.s_box[b] for b in temp])
            
            # XOR with Rcon
            temp = (int.from_bytes(temp, 'big') ^ (self.rcon[round_num-1] << 24)).to_bytes(4, 'big')
            
            # 生成第一个字
            word0 = int.from_bytes(prev_key[0:4], 'big') ^ int.from_bytes(temp, 'big')
            new_key[0:4] = word0.to_bytes(4, 'big')
            
            # 生成后续3个字
            for i in range(1, 4):
                prev_word = int.from_bytes(new_key[(i-1)*4:i*4], 'big')
                old_word = int.from_bytes(prev_key[i*4:(i+1)*4], 'big')
                new_word = prev_word ^ old_word
                new_key[i*4:(i+1)*4] = new_word.to_bytes(4, 'big')
            
            self.round_keys.append(bytes(new_key))
            print(f"Round {round_num} Key: {new_key.hex()}")

    def encrypt(self):
        """执行加密并记录中间值"""
        print("\n" + "=" * 70)
        print("加密过程")
        print("=" * 70)
        
        # 初始状态
        state = self.bytes_to_state(self.plaintext)
        self.print_state(state, "初始明文")
        
        # 第0轮：初始轮密钥加
        print("\n--- 第0轮 (初始轮密钥加) ---")
        state = self.add_round_key(state, self.round_keys[0])
        self.print_state(state, "AddRoundKey 后")
        
        # 前9轮
        for round_num in range(1, 10):
            print(f"\n--- 第{round_num}轮 ---")
            round_state = {"round": round_num, "before": [row[:] for row in state]}
            
            # SubBytes
            state = self.sub_bytes(state)
            self.print_state(state, "SubBytes 后")
            
            # ShiftRows
            state = self.shift_rows(state)
            self.print_state(state, "ShiftRows 后")
            
            # MixColumns
            state = self.mix_columns(state)
            self.print_state(state, "MixColumns 后")
            
            # AddRoundKey
            state = self.add_round_key(state, self.round_keys[round_num])
            self.print_state(state, f"AddRoundKey (Key {round_num}) 后")
            
            round_state["after"] = [row[:] for row in state]
            self.round_states.append(round_state)
        
        # 第10轮 (没有 MixColumns)
        print(f"\n--- 第10轮 ---")
        round_state = {"round": 10, "before": [row[:] for row in state]}
        
        # SubBytes
        state = self.sub_bytes(state)
        self.print_state(state, "SubBytes 后")
        
        # ShiftRows
        state = self.shift_rows(state)
        self.print_state(state, "ShiftRows 后")
        
        # AddRoundKey
        state = self.add_round_key(state, self.round_keys[10])
        self.print_state(state, f"AddRoundKey (Key 10) 后")
        
        round_state["after"] = [row[:] for row in state]
        self.round_states.append(round_state)
        
        # 最终密文
        ciphertext = self.state_to_bytes(state)
        print("\n" + "=" * 70)
        print(f"密文: {ciphertext.hex().upper()}")
        print("=" * 70)
        
        return ciphertext

    def debug_compare(self, hw_round_keys=None, hw_round_states=None):
        """
        与硬件结果比较
        hw_round_keys: 硬件生成的10轮密钥列表
        hw_round_states: 硬件每轮中间状态
        """
        print("\n" + "=" * 70)
        print("硬件结果对比")
        print("=" * 70)
        
        if hw_round_keys:
            print("\n轮密钥对比:")
            for i in range(1, 11):
                sw_key = self.round_keys[i].hex()
                hw_key = hw_round_keys[i-1] if i-1 < len(hw_round_keys) else "N/A"
                match = "✓" if sw_key == hw_key else "✗"
                print(f"Round {i:2d}: SW={sw_key}")
                print(f"          HW={hw_key} {match}")


# ============================================================
# 使用示例
# ============================================================
if __name__ == "__main__":
    # 测试向量 (NIST标准测试向量)
    # 密钥: 2b7e151628aed2a6abf7158809cf4f3c
    # 明文: 6bc1bee22e409f96e93d7e117393172a
    # 密文: 3ad77bb40d7a3660a89ecaf32466ef97
    
    key = "2b7e151628aed2a6abf7158809cf4f3c"
    plaintext = "6bc1bee22e409f96e93d7e117393172a"
    
    # 创建调试对象
    aes = AES128_Debug(key, plaintext)
    
    # 密钥扩展
    aes.key_expansion()
    
    # 加密
    ciphertext = aes.encrypt()
    
    # 打印每轮密钥供硬件验证
    print("\n" + "=" * 70)
    print("Verilog 参数 (可以直接复制到testbench)")
    print("=" * 70)
    for i, key in enumerate(aes.round_keys[1:], 1):
        key_hex = key.hex()
        # 格式化为Verilog数组
        verilog_format = '  ' + ', '.join([f"8'h{key_hex[j:j+2]}" for j in range(0, 32, 2)])
        print(f"// Round {i} Key")
        print(f"reg [7:0] round_key_{i} [0:15] = {{{verilog_format}}};")