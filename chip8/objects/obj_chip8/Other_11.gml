/// @description Reset

if surface_exists(surface) {
    surface_free(surface);
}

surface = surface_create(64, 32);

for(var i = 0;i < 2048;++ i) {
    gfx[i] = 0;
}

for(var j = 0;j < 16;++ j) {
    key[j]   = 0;
    V[j]     = 0;
    stack[j] = 0;
}

for(var k = 0;k < 4096;++ k) {
    memory[k] = 0;
}

pc     = 0x200;                 // Program counter
opcode = 0;                     // Current opcode
I      = 0;                     // Index register
sp     = 0;                     // Stack pointer

delay_timer = 0;                // Delay timer
sound_timer = 0;                // Sound timer

for(var i = 0;i < 80;++ i) {
    memory[i] = fontset[i];
}

draw_flag = true;