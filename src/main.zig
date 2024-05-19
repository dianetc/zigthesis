const std = @import("std");
const zigthesis = @import("zigthesis.zig");
const utils = @import("utils.zig");

pub fn main() void {
    zigthesis.falsify(
        struct {
            pub fn pred(args: std.meta.Tuple(&.{ i32, i32, i32 })) bool {
                const x = args[0];
                const y = args[1];
                const z = args[2];

                return (x + y) * z == x * (y + z);
            }
        }.pred,
        &[_]type{ i32, i32, i32 },
        "Example 1"
    );

    zigthesis.falsify(
        struct {
            pub fn pred(args: std.meta.Tuple(&.{ i32, i32 })) bool {
                const x = args[0];
		const y = args[1];

                return x*y == y*x;
            }
        }.pred,
        &[_]type{ i32, i32 },
        "Commutative Property of Multiplication (Integers)"
    );
    zigthesis.falsify(
        struct {
            pub fn pred(args: std.meta.Tuple(&.{ i32, i32 })) bool {
                const x = args[0];
                const y = args[1];

                return x-y == y-x;
            }
        }.pred,
        &[_]type{ i32, i32 },
        "Commutative Property of Subtraction (Integers)" 
    );
    zigthesis.falsify(
        struct {
            pub fn pred(args: std.meta.Tuple(&.{ f32, f32, f32 })) bool {
                const x = args[0];
                const y = args[1];
                const z = args[2];

                return (x + y) + z == x + (y + z);
            }
        }.pred,
        &[_]type{ f32, f32, f32},
        "Associativity of Floats"
    );
    zigthesis.falsify(
        struct {
            pub fn pred(args: std.meta.Tuple(&.{[3]i32})) bool {
                const x = args[0];

               return utils.sum(x[0..]) < 100;
            }
        }.pred,
        &[_]type{[3]i32},
        "Sum of Elements in List"
    );
}
