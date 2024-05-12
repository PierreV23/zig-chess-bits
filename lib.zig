const std = @import("std");

pub fn bitCastToArray(comptime outputT: type, input: anytype) [@typeInfo(@TypeOf(input)).Int.bits / @bitSizeOf(outputT)]outputT {
    // length of array being made
    const count = @typeInfo(@TypeOf(input)).Int.bits / @bitSizeOf(outputT);
    // amount of bytes needed to fit the input var
    const n = @typeInfo(@TypeOf(input)).Int.bits / 8 + brek: {
        const e = if (@typeInfo(@TypeOf(input)).Int.bits % 8 == 0) 0 else 1;
        break :brek e;
    };
    // new big type that is a multiple of 8
    const I = @Type(.{ .Int = .{ .bits = n * 8, .signedness = .unsigned } });
    // input stored as bytes
    var bytes: [n]u8 = @bitCast(@as(I, input));
    // sliced into `count` chunks
    const t = @Type(.{ .Int = .{ .bits = @bitSizeOf(outputT), .signedness = .unsigned } });
    const s = std.PackedIntSlice(t).init(&bytes, count);
    // return array
    var r: [count]outputT = undefined;
    inline for (0..count) |idx| {
        if (@typeInfo(outputT) == .Enum) {
            r[idx] = @enumFromInt(s.get(idx));
        } else {
            r[idx] = @bitCast(s.get(idx));
        }
    }
    return r;
}

pub fn bitCastFromArray(comptime outputT: type, array: anytype) outputT {
    var n: outputT = 0;
    const child_type = @typeInfo(@TypeOf(array)).Array.child;
    const I = @Type(.{ .Int = .{ .bits = @bitSizeOf(child_type), .signedness = .unsigned } });

    inline for (0..array.len) |idx| {
        const elem = array[array.len - 1 - idx];
        const int: I = @bitCast(elem);
        n += int;
        if (idx != array.len - 1) n <<= 4;
    }
    return n;
}

pub fn reverse_u64(num: u64) u64 {
    var result: u64 = 0;
    var n = num;

    for (0..64) |_| {
        result <<= 1;
        result |= n & 1;
        n >>= 1;
    }

    return result;
}
