const std = @import("std");

pub fn main(init: std.process.Init) !void {
    var output_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &output_buffer);
    const stdout = &stdout_writer.interface;

    var input_buffer: [1024]u8 = undefined;
    var stdin_reader = std.Io.File.stdin().reader(init.io, &input_buffer);
    const stdin = &stdin_reader.interface;

    try stdout.writeAll("Welcome to the Tip Calculator 3000!\n");
    try stdout.writeAll("Please enter the bill amounts below. Enter $0 to stop.\n");
    try stdout.flush();

    var total: f64 = 0.0;

    while (true) {
        const amount = try getFloat(stdin, stdout, "Item cost: $") orelse return;

        if (amount == 0) {
            break;
        }

        total += amount;
    }

    const tip_percentage = try getFloat(stdin, stdout, "What percentage would you like to tip? ") orelse return;
    const tip_amount = tip_percentage / 100 * total;

    try stdout.print("\nYour total bill amount is ${d}, with a tip percentage of {d}%. The total tip amount is ${d}.\n\n", .{ total, tip_percentage, tip_amount });

    try stdout.print("This comes to a total of ${d}.\n", .{total + tip_amount});
    try stdout.flush();
}

fn getInput(stdin: *std.Io.Reader, stdout: *std.Io.Writer, prompt: []const u8) !?[]const u8 {
    try stdout.writeAll(prompt);
    try stdout.flush();

    return try stdin.takeDelimiter('\n');
}

fn getFloat(stdin: *std.Io.Reader, stdout: *std.Io.Writer, prompt: []const u8) !?f64 {
    while (true) {
        const line = try getInput(stdin, stdout, prompt) orelse return null;

        const value = std.fmt.parseFloat(f64, line) catch {
            try stdout.writeAll("Fool! You didn't enter a number! Fix this mistake immediately!\n");
            continue;
        };

        if (!std.math.isFinite(value)) {
            try stdout.writeAll("Please enter a FINITE VALUE!\n");
            continue;
        }

        if (value < 0) {
            try stdout.writeAll("Bro, did you do some work for them or something? YOU CAN'T HAVE NEGATIVE NUMBERS!! geez...\n");
            continue;
        }

        // Validation complete
        return value;
    }
}
