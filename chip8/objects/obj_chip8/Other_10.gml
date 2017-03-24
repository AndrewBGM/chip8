/// @description Emulate cycle

opcode = memory[pc] << 8 | memory[pc + 1];

var lb = (opcode & 0x0F00) >> 8,
    rb = (opcode & 0x00F0) >> 4;

pc += 2;

switch(opcode & 0xF000) {
    case 0x0000:
        switch(opcode) {
            case 0x00E0:
                for(var i = 0;i < 2048;++ i) {
                    gfx[i] = 0;
                }
                
                draw_flag = true;
            break;
            
            case 0x00EE:
                pc = stack[--sp];
            break;
        }
    break;
    
    case 0x1000:
        pc = opcode & 0xFFF;
    break;
    
    case 0x2000:
        stack[sp] = pc;
        sp ++;
        pc = opcode & 0x0FFF;
    break;
    
    case 0x3000:
        if (V[lb] == (opcode & 0xFF)) {
            pc += 2;
        }
    break;
    
    case 0x4000:
        if (V[lb] != (opcode & 0x00FF)) {
            pc += 2;
        }
    break;
    
    case 0x5000:
        if (V[lb] == V[rb]) {
            pc += 2;
        }
    break;
    
    case 0x6000:
        V[lb] = opcode & 0xFF;
    break;
    
    case 0x7000:
        var val = (opcode & 0xFF) + V[lb]

        if (val > 255) {
            val -= 256;
        }

        V[lb] = val;
    break;
    
    case 0x8000:
        switch (opcode & 0x000F) {
            case 0x0000:
                V[lb] = V[rb];
            break;
            
            case 0x0001:
                V[lb] |= V[rb];
            break;
            
            case 0x0002:
                V[lb] &= V[rb];
            break;
            
            case 0x0003:
                V[lb] ^= V[rb];
            break;
            
            case 0x0004:
                V[lb] += V[rb];
                V[0xF] = +(V[lb] > 255);
                
                if (V[lb] > 255) {
                    V[lb] -= 256;
                }
            break;
            
            case 0x0005:
                V[0xF] = +(V[lb] > V[rb]);
                V[lb] -= V[rb];
                
                if (V[lb] < 0) {
                    V[lb] += 256;
                }
            break;
            
            case 0x0006:
                V[0xF] = V[lb] & 0x1;
                V[lb] = V[lb] >> 1;
            break;
            
            case 0x0007:
                V[0xF] = +(V[rb] > V[lb]);
                V[lb] = V[rb] - V[lb];
                
                if (V[lb] < 0) {
                    V[lb] += 256;
                }
            break;
            
            case 0x000E:
                V[0xF] = +(V[lb] & 0x80);
                V[lb] = V[lb] << 1;
                
                if (V[lb] > 255) {
                    V[lb] -= 256;
                }
            break;
        }
    break;
    
    case 0x9000:
        if (V[lb] != V[rb]) {
            pc += 2;
        }
        break;

    case 0xA000:
        I = opcode & 0xFFF;
    break;
    
    case 0xB000:
        pc = (opcode & 0xFFF) + V[0];
    break;
    
    case 0xC000:
        V[lb] = floor(irandom(65536) * 0xFF) & (opcode & 0xFF);
    break;
    
    case 0xD000:
        V[0xF] = 0;

        var height = opcode & 0x000F,
            registerX = V[lb],
            registerY = V[rb],
            spr = undefined;

        for (var yy = 0; yy < height; yy ++) {
            spr = memory[I + yy];
            
            for (var xx = 0; xx < 8;xx ++) {
                if ((spr & 0x80) > 0) {
                    var xpos = (registerX + xx) % 64,
                        ypos = (registerY + yy) % 32;

                    gfx[(ypos * 64) + xpos] ^= 1;
                    
                    if (!gfx[(ypos * 64) + xpos]) {
                        V[0xF] = 1;
                    }
                }
                spr = spr << 1;
            }
            
            draw_flag = true;
        }
    break;
    
    case 0xE000:
        switch (opcode & 0x00FF) {
            case 0x009E:
                if (key[V[lb]]) {
                    pc += 2;
                }
            break;
            
            case 0x00A1:
                if (!key[V[lb]]) {
                    pc += 2;
                }
            break;
        }
    break;
    
    case 0xF000:
        switch (opcode & 0x00FF) {
            case 0x0007:
                V[lb] = delay_timer;
            break;
            
            case 0x000A:
                var press = false;
                
                for(var i = 0;i < 16;i ++) {
                    if (key[i] != 0) {
                        V[(opcode & 0x0F00) >> 8] = i;
                        press = true;
                    }
                }
                
                if (!press) {
                    exit;
                }
            break;
            
            case 0x0015:
                delay_timer = V[lb];
            break;
            
            case 0x0018:
                sound_timer = V[lb];
            break;
            
            case 0x001E:
                I += V[lb];
            break;
            
            case 0x0029:
                I = V[lb] * 5;
            break;
            
            case 0x0033:
                var number = V[lb];

                for(var i = 3; i > 0;i --) {
                    memory[I + i - 1] = number % 10;
                    number /= 10;
                }
            break;
            
            case 0x0055:
                for (var i = 0; i <= lb;i ++) {
                    memory[I + i] = V[i];
                }
            break;
            
            case 0x0065:
                for (var i = 0; i <= lb;i ++) {
                    V[i] = memory[I + i];
                }
            break;
    }
    break;
}

if (delay_timer > 0) {
    -- delay_timer;
}

if (sound_timer > 0) {
    if (sound_timer == 1) {
        show_debug_message("BEEP");
    }

    -- sound_timer;
}

if (draw_flag) {
    surface_set_target(surface);
    draw_clear(c_black);
    
    for(var yy = 0;yy < 32;++ yy) {
        for(var xx = 0;xx < 64;++ xx) {
            if (gfx[(yy * 64) + xx] != 0) {
                draw_point_color(xx, yy, c_white);
            }
        }
    }
    
    surface_reset_target();
    
    draw_flag = false;
}