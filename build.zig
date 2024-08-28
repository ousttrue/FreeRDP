const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "FreeRDP",
        // .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    exe.addCSourceFiles(.{
        .files = &.{
            "server/Windows/cli/wfreerdp.c",
        },
    });
    exe.addIncludePath(b.path("include"));
    exe.addIncludePath(b.path("winpr/include"));
    exe.addIncludePath(b.path("zig-out/include"));
    exe.addIncludePath(b.path("server/windows"));
    b.installArtifact(exe);

    configHeadersStep(
        &exe.step,
        b,
        "include/config",
        &.{
            "config",
            "build-config",
            "buildflags",
            "version",
            "settings_keys",
        },
        "freerdp",
    );

    configHeadersStep(
        &exe.step,
        b,
        "winpr/include/config",
        &.{
            "config",
            "build-config",
            "buildflags",
            "version",
            "wtypes",
        },
        "winpr",
    );
}

fn configHeadersStep(
    step: *std.Build.Step,
    b: *std.Build,
    src_dir: []const u8,
    names: []const []const u8,
    dst_dir: []const u8,
) void {
    for (names) |name| {
        configHeaderStep(
            step,
            b,
            b.fmt("{s}/{s}.h.in", .{ src_dir, name }),
            b.fmt("{s}/{s}.h", .{ dst_dir, name }),
        );
    }
}

fn configHeaderStep(
    step: *std.Build.Step,
    b: *std.Build,
    src: []const u8,
    dst: []const u8,
) void {
    const config_h = b.addConfigHeader(.{
        .style = .{
            .cmake = b.path(src),
        },
    }, .{});

    const install_config_h = b.addInstallHeaderFile(
        config_h.getOutput(),
        dst,
    );

    step.dependOn(&install_config_h.step);
}
