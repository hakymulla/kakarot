from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_eq,
    uint256_le,
    uint256_sub,
    uint256_mul,
    uint256_add,
    uint256_pow2,
    uint256_unsigned_div_rem,
)
from starkware.cairo.common.bool import FALSE

// @notice Internal exponentiation of two 256-bit integers.
// @dev The result is modulo 2^256.
// @param a The base.
// @param b The exponent.
// @return The result of the exponentiation.
func uint256_exp{range_check_ptr}(a: Uint256, b: Uint256) -> Uint256 {
    let one_uint = Uint256(1, 0);
    let zero_uint = Uint256(0, 0);

    let (is_b_zero) = uint256_eq(b, zero_uint);
    if (is_b_zero != FALSE) {
        return one_uint;
    }
    let (b_minus_one) = uint256_sub(b, one_uint);
    let pow = uint256_exp(a, b_minus_one);
    let (res, _) = uint256_mul(a, pow);
    return res;
}

// @notice Extend a signed number which fits in N bytes to 32 bytes.
// @param x The number to be sign extended.
// @param byte_num The size in bytes minus one of x to consider.
// @returns x if byteNum > 31, or x interpreted as a signed number with sign-bit at (byte_num*8+7), extended to the full 256 bits
func uint256_signextend{range_check_ptr}(x: Uint256, byte_num: Uint256) -> Uint256 {
    alloc_locals;
    let (byte_num_gt_word_size) = uint256_le(Uint256(32, 0), byte_num);
    if (byte_num_gt_word_size != 0) {
        return x;
    }

    let sign_bit_position = byte_num.low * 8 + 7;

    let (s) = uint256_pow2(Uint256(sign_bit_position, 0));
    let (sign_bit, value) = uint256_unsigned_div_rem(x, s);
    let (_, x_is_negative) = uint256_unsigned_div_rem(sign_bit, Uint256(2, 0));

    if (x_is_negative.low == 0) {
        return value;
    }

    let (mask) = uint256_sub(s, Uint256(1, 0));
    let max_uint256 = Uint256(2 ** 128 - 1, 2 ** 128 - 1);
    let (padding) = uint256_sub(max_uint256, mask);
    let (value, _) = uint256_add(value, padding);
    return value;
}