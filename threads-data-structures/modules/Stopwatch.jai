#import "POSIX";

Stopwatch :: struct {
    start, end : timespec;
    elapsed_time_nsec : s64;
};

StartStopwatch :: inline (stopwatch : *Stopwatch) {
    using clockid_t;
    using (stopwatch.*);
    clock_gettime(CLOCK_MONOTONIC, *(stopwatch.start));
}

EndStopwatch :: inline (stopwatch : *Stopwatch) {
    using clockid_t;
    using (stopwatch.*);
    clock_gettime(CLOCK_MONOTONIC, *end);
    elapsed_time_nsec = (end.tv_sec - start.tv_sec) * 1_000_000_000 + (end.tv_nsec - start.tv_nsec);
}
