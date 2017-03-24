var f    = file_bin_open(get_open_filename("All Files|*.*", ""), 0),
    size = file_bin_size(f);

rom_loaded = true;
event_user(1);

if((4096-512) > size) {
    for(var i = 0;i < size;++ i) {
        memory[i + 512] = file_bin_read_byte(f);
    }
} else {
    rom_loaded = false;
}

file_bin_close(f);