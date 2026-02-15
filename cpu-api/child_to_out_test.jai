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
    
    x := 100;
    
    PrintWithProcessId("hello from parent: %\n", x);

    rc := fork();
    assert(rc > -1, "Fork failed!\n");

    if rc == 0 { // child process
        close(STDOUT_FILENO);
        file := open("out_test", O_WRONLY);
        x = 50;
        PrintWithProcessId("goo goo gaa gaa: %\n", x);

        /*
        child_string := "goo goo gaa gaa\n";
        for 0..99 {
            child_bytes_written := write(file, child_string.data, xx child_string.count);
            assert(child_bytes_written > -1, "Child failed to write bytes");
        }
        */
    } else {
        wait(null);
        for 0..99 PrintWithProcessId("AHHHHH\n", x);

        /*
        parent_string := "pay your damn taxes\n";
        for 0..99 {
            parent_bytes_written := write(file, parent_string.data, xx parent_string.count);
            assert(parent_bytes_written > -1, "Parent failed to write bytes");
        }
        */
    }
}
