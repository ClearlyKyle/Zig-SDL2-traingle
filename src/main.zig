const std = @import("std");
const SDL = @cImport(@cInclude("SDL2/SDL.h"));

pub fn main() anyerror!void {
    std.debug.print("Starting program!\n", .{});

    if (SDL.SDL_Init(SDL.SDL_INIT_EVERYTHING) < 0)
        sdlPanic();

    // WINDOW
    const window = SDL.SDL_CreateWindow(
        "SDL Zig Example",
        SDL.SDL_WINDOWPOS_CENTERED,
        SDL.SDL_WINDOWPOS_CENTERED,
        800,
        600,
        SDL.SDL_WINDOW_SHOWN,
    ) orelse sdlPanic();

    // RENDERER
    const renderer = SDL.SDL_CreateRenderer(window, -1, SDL.SDL_RENDERER_ACCELERATED) orelse sdlPanic();

    // On exit
    defer _ = SDL.SDL_DestroyWindow(window);
    defer _ = SDL.SDL_DestroyRenderer(renderer);
    defer _ = SDL.SDL_Quit();

    // Triangle verticies
    const vertices = [_]SDL.SDL_Vertex{
        .{
            .position = .{ .x = 400, .y = 150 },
            .color = .{ .r = 255, .g = 0, .b = 0, .a = 255 },
            .tex_coord = .{ .x = 0, .y = 0 },
        },
        .{
            .position = .{ .x = 200, .y = 450 },
            .color = .{ .r = 0, .g = 0, .b = 255, .a = 255 },
            .tex_coord = .{ .x = 0, .y = 0 },
        },
        .{
            .position = .{ .x = 600, .y = 450 },
            .color = .{ .r = 0, .g = 255, .b = 0, .a = 255 },
            .tex_coord = .{ .x = 0, .y = 0 },
        },
    };

    // Main window loop
    mainLoop: while (true) {
        var ev: SDL.SDL_Event = undefined;
        while (SDL.SDL_PollEvent(&ev) != 0) {
            switch (ev.type) {
                SDL.SDL_QUIT => break :mainLoop,
                SDL.SDL_KEYDOWN => {
                    switch (ev.key.keysym.scancode) {
                        SDL.SDL_SCANCODE_ESCAPE => break :mainLoop,
                        else => std.log.info("key pressed: {}\n", .{ev.key.keysym.scancode}),
                    }
                },

                else => {},
            }
        }

        _ = SDL.SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL.SDL_ALPHA_OPAQUE);
        _ = SDL.SDL_RenderClear(renderer);
        _ = SDL.SDL_RenderGeometry(
            renderer,
            null,
            &vertices,
            vertices.len,
            null,
            0,
        );

        SDL.SDL_RenderPresent(renderer);
    }
}

fn sdlPanic() noreturn {
    const str = @as(?[*:0]const u8, SDL.SDL_GetError()) orelse "unknown error";
    @panic(std.mem.sliceTo(str, 0));
}
