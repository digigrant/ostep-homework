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

    file_descriptors : [2] s32;
    result := pipe(*file_descriptors);
    assert(result > -1, "Failed to create pipe.\n");
    PrintWithProcessId("A pipe for my children: %\n", file_descriptors);

    first_rc := fork();
    assert(first_rc > -1, "First fork failed!\n");

    if first_rc == 0 { // first child process - writes
        close(file_descriptors[0]);
        x = 50;
        my_secret := sprint("hey.... goo goo gaa gaa... x = %", x);
        write(file_descriptors[1], my_secret.data, xx my_secret.count);
        close(file_descriptors[1]);
        return;
    }

    second_rc := fork();
    assert(second_rc > -1, "Second fork failed!\n");
    
    if second_rc == 0 { // second child process - reads
        close(file_descriptors[1]);
        buffer : string = ---;
        buffer.count = 100;
        buffer.data = alloc(100);
        num_bytes_read := read(file_descriptors[0], buffer.data, 100);
        PrintWithProcessId("Bro just said: %\n", buffer);
        close(file_descriptors[0]);
        return;
    }

    // parent
    PrintWithProcessId("My babies: %, %\n", first_rc, second_rc);
    
}
