'''# 测试数据
a = 0x01234567
b = 0x89abcdef
n = 0xfffffffb
R = 0x100000000

# 计算 n_inv = n^(-1) mod R
n_inv = R-pow(n, -1, R)

print("=" * 60)
print("Montgomery乘法三步调试")
print("=" * 60)

# 步骤1: T = a * b
T = a * b
print(f"\n步骤1: T = a * b")
print(f"  a       = {hex(a)}")
print(f"  b       = {hex(b)}")
print(f"  T       = {hex(T)}")

# 步骤2: m = (T mod R) * n_inv mod R
T_mod_R = T % R
m_raw = T_mod_R * n_inv
m = m_raw % R
print(f"\n步骤2: m = (T mod R) * n_inv mod R")
print(f"  T mod R          = {hex(T_mod_R)}")
print(f"  n_inv            = {hex(n_inv)}")
print(f"  (T mod R)*n_inv  = {hex(m_raw)}")
print(f"  m                = {hex(m)}")

# 步骤3: t = (T + m * n) / R
m_times_n = m * n
T_plus_mn = T + m_times_n
t = T_plus_mn // R
remainder = T_plus_mn % R

print(f"\n步骤3: t = (T + m * n) / R")
print(f"  m * n            = {hex(m_times_n)}")
print(f"  T + m*n          = {hex(T_plus_mn)}")
print(f"  (T + m*n) / R    = {hex(t)}")
print(f"  (T + m*n) % R    = {hex(remainder)} (应为0)")

# 最终结果
result = t % n
expected = (a * b * pow(R, -1, n)) % n

print(f"\n最终结果:")
print(f"  t mod n          = {hex(result)}")
print(f"  预期结果         = {hex(expected)}")
print(f"  结果正确         = {result == expected}")

# 简洁输出
print("\n" + "=" * 60)
print("简洁结果:")
print(f"T      = {hex(T)}")
print(f"m      = {hex(m)}")
print(f"t      = {hex(t)}")
print(f"结果   = {hex(result)}")
print(hex(0x2842dad436b1b9d7+0xc94e4629))
'''
def montgomery_radix2(a, b, n):
    """
    计算 a * b * 2^{-width} mod n
    算法：
        T = 0
        for i in range(width):
            if (b >> i) & 1:      # b[i] == 1
                T = T + a
            if T & 1:              # T 是奇数
                T = T + n
            T = T >> 1              # 右移一位（除以 2）
        if T >= n:
            T = T - n
        return T
    """
    width = n.bit_length()
    print(f"===== Montgomery 模乘 =====")
    print(f"a = 0x{a:X} ({a})")
    print(f"b = 0x{b:X} ({b})")
    print(f"n = 0x{n:X} ({n})")
    print(f"位宽 = {width} 位")
    print("=" * 50)

    T = 0
    for i in range(width):
        print(f"\n--- 第 {i:2d} 轮 ---")
        bit = (b >> i) & 1
        print(f"  b[{i}] = {bit}")

        # 步骤 1: 如果 b[i] == 1，加 a
        if bit:
            T_before = T
            T = T + a
            print(f"  加 a: 0x{T_before:X} + 0x{a:X} = 0x{T:X}")

        # 步骤 2: 如果 T 是奇数，加 n
        if T & 1:
            T_before = T
            T = T + n
            print(f"  加 n (奇数): 0x{T_before:X} + 0x{n:X} = 0x{T:X}")
        else:
            print(f"  T 是偶数 (0x{T:X}[0]=0)，不加 n")

        # 步骤 3: 右移一位（除以 2）
        T_before = T
        T = T >> 1
        print(f"  右移: 0x{T_before:X} >> 1 = 0x{T:X}")

    print("\n" + "=" * 50)
    print(f"循环结束，T = 0x{T:X} ({T})")

    # 最终减法
    if T >= n:
        print(f"T >= n，减 n: 0x{T:X} - 0x{n:X} = 0x{T - n:X}")
        T = T - n
    else:
        print(f"T < n，无需减法 (0x{T:X} < 0x{n:X})")

    print(f"最终结果 = 0x{T:X}")
    return T


# 测试用例
if __name__ == "__main__":
    # 你的测试数据
    a=0x89abcdef89abcdef89abcdef89abcdef89abcdef89abcdef89abcdef89abcdef;
    b=57448972955402726528454876578424267210853927114427293053654687936952302948223;
    n=111079669216464751073942009743976564074175800489696573048427645366541613384429;

    print(f"输入数据:")
    print(f"a = 0x{a:X}")
    print(f"b = 0x{b:X}")
    print(f"n = 0x{n:X}")
    print(f"n 的位宽 = {n.bit_length()} 位")
    print("-" * 50)

    result = montgomery_radix2(a, b, n)
    
    print("\n" + "=" * 50)
    print(f"最终 Montgomery 结果 = 0x{result:X}")

    # 验证：普通模乘
    expected = (a * b) % n
    print(f"普通模乘结果 = 0x{expected:X}")

    # 验证 Montgomery 结果是否正确（需要乘回 2^width）
    R = 1 << n.bit_length()
    R_inv = pow(R, -1, n)  # Python 3.8+ 支持
    print(hex((a*b*R_inv)%n))