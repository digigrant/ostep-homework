#import "POSIX";
#import "Basic";
#import "String";

main :: () {
    PrintWithProcessId :: (formatted_string : string, args : .. Any) -> bytes_printed : s64 {
        return print("(%) %", getpid(), sprint(formatted_string, .. args));
    }

    /*
    file := open("test", O_RDWR, O_CREAT);
    assert(file != 0, "Failed to open file\n");
    test_str := "my big stinky test\n";
    num_bytes_written := write(file, test_str.data, xx test_str.count);
    print("Wrote % bytes just now\n", num_bytes_written);
    assert(num_bytes_written > -1, "Failed to write bytes");
    */

    args := get_command_line_arguments();
    assert(args.count == 2, "you need to give an argument: the number of processes");
    
    x : int = parse_int(*args[1]);
    assert(x > -1 && x < 11, "0-10 processes please");
    
    PrintWithProcessId("hello from parent: %\n", x);
    if x == 0 return;
    
    rc := fork();
    assert(rc >= 0, "Fork failed!\n");

    if rc == 0 { // child process
        PrintWithProcessId("baby says x = %.\n", x);

        program_name := "my_program";
        int_arg := sprint("%", x-1);
        argv : [3] *u8 = .[program_name.data, int_arg.data, cast(*u8) null];
        execv(program_name.data, cast(**u8) *argv);
        assert(false, "Failed to execute program.\n");

        /*
        child_string := "goo goo gaa gaa\n";
        for 0..99 {
            child_bytes_written := write(file, child_string.data, xx child_string.count);
            assert(child_bytes_written > -1, "Child failed to write bytes");
        }
        */
    } else {
        rc_wait := wait(null);
        PrintWithProcessId("parent says x = %.\n", x);

        /*
        parent_string := "pay your damn taxes\n";
        for 0..99 {
            parent_bytes_written := write(file, parent_string.data, xx parent_string.count);
            assert(parent_bytes_written > -1, "Parent failed to write bytes");
        }
        */
    }
}
