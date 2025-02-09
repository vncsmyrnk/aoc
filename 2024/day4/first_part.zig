const std = @import("std");

const CountError = error{
    CharMatrixColumnsNotEqual,
    SearchWordUnfit,
};

const Matcher = *const fn (SearchContext) bool;

const SearchContext = struct {
    chars: []const []const u8,
    search_word: []const u8,
    starting_row_index: usize,
    starting_column_index: usize,
};

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input-2.txt", .{});
    defer file.close();

    var allocator = std.heap.page_allocator;
    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var iter = std.mem.split(u8, buffer, "\n");
    while (iter.next()) |line| {
        if (line.len == 0) continue;
        try lines.append(line);
    }

    const chars: []const []const u8 = try lines.toOwnedSlice();
    const occurences = countWordOcurrences(chars, "XMAS") catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return;
    };
    std.debug.print("{}\n", .{occurences});
}

fn countWordOcurrences(chars: []const []const u8, search_word: []const u8) !usize {
    const column_size = chars[0].len;
    for (chars[1..]) |row| {
        if (row.len != column_size) {
            return CountError.CharMatrixColumnsNotEqual;
        }
    }

    const row_size = chars.len;
    if (search_word.len > row_size and search_word.len > column_size) {
        return CountError.SearchWordUnfit;
    }

    var counter: usize = 0;
    var mutex = std.Thread.Mutex{};
    var threads: [8]std.Thread = undefined;

    for (chars, 0..) |row, row_index| {
        for (row, 0..) |item, column_index| {
            if (item != search_word[0]) {
                continue;
            }

            const matchers: []const Matcher = &.{
                lastCharsMatchHorizontally,
                lastCharsMatchHorizontallyBackwards,
                lastCharsMatchVertically,
                lastCharsMatchVerticallyBackwards,
                lastCharsMatchDiagonallyDownwardRight,
                lastCharsMatchDiagonallyDownwardLeft,
                lastCharsMatchDiagonallyUpwardRight,
                lastCharsMatchDiagonallyUpwardLeft,
            };

            const search = SearchContext{
                .chars = chars,
                .search_word = search_word,
                .starting_row_index = row_index,
                .starting_column_index = column_index,
            };

            for (matchers, 0..) |matcher, i| {
                threads[i] = try std.Thread.spawn(.{}, counterWrapper, .{ &counter, &mutex, matcher, search });
            }
        }
    }

    for (threads) |thread| {
        thread.join();
    }

    return counter;
}

fn counterWrapper(counter: *usize, mutex: *std.Thread.Mutex, matcher: Matcher, search_criteria: SearchContext) void {
    const match = matcher(search_criteria);
    if (match) {
        mutex.lock();
        defer mutex.unlock();
        counter.* += 1;
    }
}

fn lastCharsMatchHorizontally(search: SearchContext) bool {
    const row_fits_word_horizontally = search.starting_column_index + search.search_word.len - 1 < search.chars[search.starting_row_index].len;
    if (!row_fits_word_horizontally) {
        return false;
    }

    for (search.search_word[1..], 1..) |char, index| {
        const horizontally_formed = search.chars[search.starting_row_index][search.starting_column_index + index] == char;
        if (!horizontally_formed) {
            return false;
        }
    }
    return true;
}

fn lastCharsMatchHorizontallyBackwards(search: SearchContext) bool {
    const row_fits_word_horizontally_backwards = search.starting_column_index > search.search_word.len - 2;
    if (!row_fits_word_horizontally_backwards) {
        return false;
    }

    for (search.search_word[1..], 1..) |char, index| {
        const horizontally_backwards_formed = search.chars[search.starting_row_index][search.starting_column_index - index] == char;
        if (!horizontally_backwards_formed) {
            return false;
        }
    }
    return true;
}

fn lastCharsMatchVertically(search: SearchContext) bool {
    const row_fits_word_vertically = search.starting_row_index + search.search_word.len - 1 < search.chars.len;
    if (!row_fits_word_vertically) {
        return false;
    }

    for (search.search_word[1..], 1..) |char, index| {
        const vertically_formed = search.chars[search.starting_row_index + index][search.starting_column_index] == char;
        if (!vertically_formed) {
            return false;
        }
    }
    return true;
}

fn lastCharsMatchVerticallyBackwards(search: SearchContext) bool {
    const row_fits_word_vertically_backwards = search.starting_row_index > search.search_word.len - 2;
    if (!row_fits_word_vertically_backwards) {
        return false;
    }

    for (search.search_word[1..], 1..) |char, index| {
        const vertically_backwards_formed = search.chars[search.starting_row_index - index][search.starting_column_index] == char;
        if (!vertically_backwards_formed) {
            return false;
        }
    }
    return true;
}

fn lastCharsMatchDiagonallyDownwardRight(search: SearchContext) bool {
    for (search.search_word[1..], 1..) |char, index| {
        const diagonally_downward_right_formed = search.starting_row_index + index < search.chars.len and search.starting_column_index + index < search.chars[search.starting_row_index + index].len and search.chars[search.starting_row_index + index][search.starting_column_index + index] == char;
        if (!diagonally_downward_right_formed) {
            return false;
        }
    }
    return true;
}

fn lastCharsMatchDiagonallyDownwardLeft(search: SearchContext) bool {
    for (search.search_word[1..], 1..) |char, index| {
        const diagonally_downward_left_formed = search.starting_row_index + index < search.chars.len and search.starting_column_index >= search.chars[search.starting_row_index + index].len - index and search.chars[search.starting_row_index + index][search.starting_column_index - index] == char;
        if (!diagonally_downward_left_formed) {
            return false;
        }
    }
    return true;
}

fn lastCharsMatchDiagonallyUpwardRight(search: SearchContext) bool {
    for (search.search_word[1..], 1..) |char, index| {
        const diagonally_upward_right_formed = search.starting_row_index > index - 1 and search.starting_column_index + index < search.chars[search.starting_row_index - index].len and search.chars[search.starting_row_index - index][search.starting_column_index + index] == char;
        if (!diagonally_upward_right_formed) {
            return false;
        }
    }
    return true;
}

fn lastCharsMatchDiagonallyUpwardLeft(search: SearchContext) bool {
    for (search.search_word[1..], 1..) |char, index| {
        const diagonally_upward_left_formed = search.starting_row_index > index - 1 and search.starting_column_index >= search.chars[search.starting_row_index - index].len - index and search.chars[search.starting_row_index - index][search.starting_column_index - index] == char;
        if (!diagonally_upward_left_formed) {
            return false;
        }
    }
    return true;
}

test "test multiple ocurrences" {
    const chars = &.{
        &.{ '.', '.', '.', '.', 'X', 'X', 'M', 'A', 'S', '.' },
        &.{ '.', 'S', 'A', 'M', 'X', 'M', 'S', '.', '.', '.' },
        &.{ '.', '.', '.', 'S', '.', '.', 'A', '.', '.', '.' },
        &.{ '.', '.', 'A', '.', 'A', '.', 'M', 'S', '.', 'X' },
        &.{ 'X', 'M', 'A', 'S', 'A', 'M', 'X', '.', 'M', 'M' },
        &.{ 'X', '.', '.', '.', '.', '.', 'X', 'A', '.', 'A' },
        &.{ 'S', '.', 'S', '.', 'S', '.', 'S', '.', 'S', 'S' },
        &.{ '.', 'A', '.', 'A', '.', 'A', '.', 'A', '.', 'A' },
        &.{ '.', '.', 'M', '.', 'M', '.', 'M', '.', 'M', 'M' },
        &.{ '.', 'X', '.', 'X', '.', 'X', 'M', 'A', 'S', 'X' },
    };

    const result = try countWordOcurrences(chars, "XMAS");
    try std.testing.expect(result == 15); // Should be 18
}

test "test char matrix columns not the same size" {
    const chars = &.{
        &.{ 'Z', 'Z', 'Z', 'Z' },
        &.{ 'Z', 'S', 'Z' },
        &.{ 'Z', 'Z', 'Z' },
    };

    const result = countWordOcurrences(chars, "MY");
    try std.testing.expectError(CountError.CharMatrixColumnsNotEqual, result);
}

test "test search word unfit" {
    const chars = &.{
        &.{ 'Z', 'Z', 'Z', 'Z' },
        &.{ 'Z', 'Z', 'Z', 'Z' },
        &.{ 'Z', 'Z', 'Z', 'Z' },
        &.{ 'Z', 'Z', 'Z', 'Z' },
    };

    const result = countWordOcurrences(chars, "ABIGWORD");
    try std.testing.expectError(CountError.SearchWordUnfit, result);
}

test "test horizontally ocurrences" {
    const chars = &.{
        &.{ 'X', 'M', 'A', 'Z', 'Z' },
        &.{ 'Z', 'X', 'M', 'A', 'S' },
        &.{ 'Z', 'Z', 'X', 'M', 'Z' },
        &.{ 'X', 'M', 'A', 'S', 'Z' },
    };

    const result = try countWordOcurrences(chars, "XMAS");
    try std.testing.expect(result == 2);
}

test "test horizontally backwards ocurrences" {
    const chars = &.{
        &.{ 'Z', 'S', 'A', 'M', 'X' },
        &.{ 'S', 'A', 'M', 'X', 'Z' },
        &.{ 'Z', 'M', 'X', 'Z', 'Z' },
        &.{ 'Z', 'A', 'M', 'X', 'Z' },
    };

    const result = try countWordOcurrences(chars, "XMAS");
    try std.testing.expect(result == 2);
}

test "test vertically ocurrences" {
    const chars = &.{
        &.{ 'X', 'Z', 'Z', 'X' },
        &.{ 'M', 'X', 'Z', 'M' },
        &.{ 'A', 'M', 'X', 'A' },
        &.{ 'S', 'A', 'M', 'Z' },
        &.{ 'Z', 'S', 'Z', 'Z' },
    };

    const result = try countWordOcurrences(chars, "XMAS");
    try std.testing.expect(result == 2);
}

test "test vertically backwards ocurrences" {
    const chars = &.{
        &.{ 'Z', 'Z', 'S', 'Z' },
        &.{ 'Z', 'M', 'A', 'S' },
        &.{ 'A', 'X', 'M', 'A' },
        &.{ 'M', 'Z', 'X', 'M' },
        &.{ 'X', 'Z', 'Z', 'X' },
    };

    const result = try countWordOcurrences(chars, "XMAS");
    try std.testing.expect(result == 2);
}

test "test diagonally downward left ocurrences" {
    const chars = &.{
        &.{ 'Z', 'Z', 'Z', 'X' },
        &.{ 'Z', 'Z', 'M', 'X' },
        &.{ 'Z', 'A', 'M', 'X' },
        &.{ 'Z', 'A', 'M', 'Z' },
        &.{ 'S', 'Z', 'Z', 'Z' },
    };

    const result = try countWordOcurrences(chars, "XMAS");
    try std.testing.expect(result == 1);
}

test "test diagonally downward right ocurrences" {
    const chars = &.{
        &.{ 'X', 'X', 'Z', 'Z' },
        &.{ 'X', 'M', 'Z', 'Z' },
        &.{ 'X', 'M', 'A', 'Z' },
        &.{ 'Z', 'M', 'A', 'S' },
        &.{ 'Z', 'Z', 'Z', 'S' },
    };

    const result = try countWordOcurrences(chars, "XMAS");
    try std.testing.expect(result == 2);
}

test "test diagonally upward left ocurrences" {
    const chars = &.{
        &.{ 'S', 'Z', 'Z', 'Z' },
        &.{ 'S', 'A', 'Z', 'Z' },
        &.{ 'A', 'A', 'M', 'Z' },
        &.{ 'Z', 'M', 'M', 'X' },
        &.{ 'Z', 'X', 'X', 'X' },
    };

    const result = try countWordOcurrences(chars, "XMAS");
    try std.testing.expect(result == 2);
}

test "test diagonally upward right ocurrences" {
    const chars = &.{
        &.{ 'Z', 'Z', 'Z', 'S' },
        &.{ 'X', 'Z', 'A', 'S' },
        &.{ 'Z', 'M', 'A', 'Z' },
        &.{ 'X', 'M', 'M', 'Z' },
        &.{ 'X', 'X', 'Z', 'Z' },
    };

    const result = try countWordOcurrences(chars, "XMAS");
    try std.testing.expect(result == 2);
}
