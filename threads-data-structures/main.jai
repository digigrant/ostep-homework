#import "System";
using,except(max,min) Basic :: #import "Basic";
#import "Math";

main :: () {
    time_a, time_b : u64;

    diffs : [100] u64;
    for 0..99 {
        time_a = read_cpu_counter();
        time_b = read_cpu_counter();
        diffs[it] = time_b - time_a;
        print("%: %, % (%)\n", it, time_a, time_b, diffs[it]);
    }
    max : u64 = 0;
    min : u64 = U64_MAX;
    sum : u64 = 0;
    for diff : diffs {
        max = Basic.max(max, diff);
        min = Basic.min(min, diff);
        sum += diff;
    }
    avg := sum / 100.0;
    print("---\n");
    print("Max: %\n", max);
    print("Min: %\n", min);
    print("Avg: %\n", avg);
}
