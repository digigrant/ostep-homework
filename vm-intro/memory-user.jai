#import "Basic";
#import "String";
#import "POSIX";

main :: () {
    args := get_command_line_arguments();

    assert(args.count > 1, "Not enough args");

    num_of_megabytes := parse_int(*(args[1]));
    num_of_bytes := num_of_megabytes * 1024 * 1024;

    print("(%) %\n", getpid(), num_of_megabytes);

    my_fat_buffer := cast(*u8) alloc(num_of_bytes);
    defer free(my_fat_buffer);

    memset(my_fat_buffer, 0, num_of_bytes);

    while true {
        for 0..num_of_bytes-1 my_fat_buffer[it] += 1;
        for 0..num_of_bytes-1 my_fat_buffer[it] -= 1;
    }
}
