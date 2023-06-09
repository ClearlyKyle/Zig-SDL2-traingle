const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});
    const exe = b.addExecutable(.{
        .name = "example",
        .root_source_file = .{ .path = "src/main.zig" },
        .optimize = optimize,
        .target = target,
    });

    if (builtin.cpu.arch == .x86_64 and builtin.os.tag == .windows) {
        exe.addVcpkgPaths(.dynamic) catch {};
        if (exe.vcpkg_bin_path) |path| {
            std.debug.print("Using : vcpkg and linkSystemLibraryName(\"sdl\")\n", .{});

            // we found SDL2 in vcpkg, just install and use this variant
            const src_path = std.fs.path.join(b.allocator, &.{ path, "SDL2.dll" }) catch @panic("out of memory");
            std.debug.print("src_path : {s}\n", .{src_path});

            exe.linkSystemLibraryName("sdl2");
            b.installBinFile(src_path, "SDL2.dll");
        } else {
            // Linking dynamically
            //exe.addIncludePath("deps/include/SDL2");
            //exe.addLibraryPath("deps/lib/x64");
            //exe.linkSystemLibraryName("sdl2");
            //exe.install();

            // Linking statically
            //exe.linkLibC();
            //exe.addIncludePath("deps/include/SDL2");
            //exe.addObjectFile("deps/lib/x64/SDL2.lib");
            //exe.install();
        }
    } else {
        std.debug.print("Using : linkSystemLibrary(\"sdl\")\n", .{});
        exe.linkSystemLibrary("sdl2");
    }

    exe.linkLibC();

    const run = b.step("run", "Run the demo");
    const run_cmd = exe.run();
    run.dependOn(&run_cmd.step);

    defer std.debug.print("Build complete\n", .{});
}
