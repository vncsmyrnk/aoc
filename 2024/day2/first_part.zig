const std = @import("std");

// TODO: This needs optmization and cleaning

const Order = enum { ascending, descending };

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var allocator = std.heap.page_allocator;

    const file_contents = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(file_contents);

    var lines = std.mem.split(u8, file_contents, "\n");

    var safe_lines: usize = 0;

    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var numbers = std.mem.split(u8, line, " ");

        var prev_number: ?i32 = null;

        var i: usize = 0;
        var line_order: ?Order = null;

        while (numbers.next()) |num_str| {
            if (num_str.len == 0) continue;
            i += 1;

            const cur = try std.fmt.parseInt(i32, num_str, 10);

            if (i == 1) {
                prev_number = cur;
                continue;
            }

            const prev = prev_number orelse unreachable;

            if (prev == cur) {
                break;
            }

            if (i == 2) {
                line_order = if (prev > cur) Order.descending else Order.ascending;
            }

            if (i >= 2) {
                if (prev > cur and line_order == Order.ascending) {
                    break;
                } else if (prev < cur and line_order == Order.descending) {
                    break;
                }

                const diff = prev - cur;
                if (diff > 3 or diff < -3) {
                    break;
                }
            }

            prev_number = cur;

            if (numbers.peek() == null) {
                safe_lines += 1;
            }
        }
    }

    std.debug.print("{d}\n", .{safe_lines});
}
