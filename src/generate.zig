const std = @import("std");

fn GenerateImplReturn(comptime arg_types: []const type) type {
    return struct {
        fn create() @This() {
            const ArgTuple = std.meta.Tuple(arg_types);
            var args: ArgTuple = undefined;
            comptime var i = 0;
            inline while (i < arg_types.len) : (i += 1) {
                const field_type = arg_types[i];
                @field(args, std.meta.fields(ArgTuple)[i].name) = generate(field_type);
            }
            return @This(){ .tuple = args };
        }

        pub fn tuple(self: @This()) std.meta.Tuple(arg_types) {
            return self.tuple;
        }

        tuple: std.meta.Tuple(arg_types),
    };
}

fn generate_impl(arg_types: []const type) GenerateImplReturn(arg_types) {
    return GenerateImplReturn(arg_types).create();
}

pub fn createGenerator(arg_types: []const type) type {
    return struct {
        pub fn generate() std.meta.Tuple(arg_types) {
            const impl = generate_impl(arg_types);
            return impl.tuple;
        }
    };
}

fn generate(comptime T: type) T {
    switch(@typeInfo(T)) {
        .Int => {
            return IntGenerator(T).generate();
        },
        .Float => {
            return FloatGenerator(T).generate();
        },
        .Array => |array_info| {
            return ArrayGenerator(array_info.child, array_info.len).generate();
        },
        else => @compileError("Type not supported") 
    }
}

fn IntGenerator(comptime T: type) type {
    return struct{
        pub fn generate() T {
            return std.crypto.random.intRangeAtMost(T,std.math.pow(i32,-10,3),std.math.pow(i32,10,3));
        }
    };
        
}

fn FloatGenerator(comptime T: type) type {
    return struct {
        pub fn generate() T {
            return std.crypto.random.float(T);
        }
    };
}

fn ArrayGenerator(comptime T: type, comptime n: usize) type {
    return struct {
        pub fn generate() [n]T {
            var array: [n]T = undefined;
            for (&array) |*item| {
                item.* = generateElement(T);
            }
            return array;
        }

        fn generateElement(comptime ElementType: type) ElementType {
            return switch (@typeInfo(ElementType)) {
                .Int => IntGenerator(ElementType).generate(),
                .Float => FloatGenerator(ElementType).generate(),
                else => @compileError("Element type not supported"),
            };
        }
    };
}