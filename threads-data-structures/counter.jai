#import "POSIX";
#import "Basic";
#import "String";
#import "Stopwatch";

main_counter : u64 = 0;
main_counter_lock : pthread_mutex_t;

thread_counters : [..] u64;
thread_locks : [..] pthread_mutex_t;
thread_worker_sloppy_args : [..] ThreadWorkerSloppyArgs;

thread_increment_amount : u64;
thread_counter_push_threshold : u64;

GetCounter :: () -> u64 {
    result : u64;
    pthread_mutex_lock(*main_counter_lock);
    result = main_counter;
    pthread_mutex_unlock(*main_counter_lock);
    return result;
}

//*** normal counter implmentation
ThreadWorker :: (amount : *void) -> *void #c_call {
    for 0..thread_increment_amount-1 IncrementCounter();
    return null;
}

IncrementCounter :: () #c_call {
    // acquire main lock and directly update main counter
    pthread_mutex_lock(*main_counter_lock);
    main_counter += 1;
    pthread_mutex_unlock(*main_counter_lock);
}

//*** sloppy counter implementation
ThreadWorkerSloppyArgs :: struct {
    thread_counter : *u64;
    thread_lock : *pthread_mutex_t;
}

ThreadWorkerSloppy :: (args : *void) -> *void #c_call {
    thread_args := cast(*ThreadWorkerSloppyArgs) args;
    for 0..thread_increment_amount-1 IncrementCounterSloppy(thread_args);

    // handle any leftover amount that wasnt pushed yet
    leftover_amount : u64;
    using thread_args;
    pthread_mutex_lock(thread_lock);
    leftover_amount = (thread_counter.*);
    (thread_counter.*) = 0;
    pthread_mutex_unlock(thread_lock);
    if leftover_amount > 0 PushToMainCounter(leftover_amount);

    return null;
}

IncrementCounterSloppy :: (thread_args : *ThreadWorkerSloppyArgs) #c_call {
    using thread_args;

    // claim thread lock and update thread counter
    pthread_mutex_lock(thread_lock);
    (thread_counter.*) += 1;
    
    if (thread_counter.*) == thread_counter_push_threshold {
        PushToMainCounter(thread_counter.*);
        (thread_counter.*) = 0;
    }
    
    pthread_mutex_unlock(thread_lock);
}

PushToMainCounter :: (amount : u64) #c_call {
    // claim main lock and update main counter
    pthread_mutex_lock(*main_counter_lock);
    main_counter += amount;
    pthread_mutex_unlock(*main_counter_lock);
}

main :: () {
    args := get_command_line_arguments();
    assert(args.count >= 3 && args.count <= 4, "counter.jai <thread_count> <thread_increment_amount> [<thread_counter_push_threshold>]\n");

    thread_count := xx parse_int(*args[1]);
    print("Thread count: %\n", thread_count);

    thread_increment_amount = xx parse_int(*args[2]);
    print("Increment amount: %\n", thread_increment_amount);

    is_sloppy := args.count == 4;
    if is_sloppy thread_counter_push_threshold = xx parse_int(*args[3]);
    print("Mode: %\n", ifx !is_sloppy "Normal" else sprint("Sloppy (%)", thread_counter_push_threshold)); 

    threads : [..] pthread_t;
    array_resize(*threads, thread_count, false);
    
    thread_ids : [..] s32;
    array_resize(*thread_ids, thread_count, false);

    // init main counter and lock
    main_counter = 0;
    pthread_mutex_init(*main_counter_lock, null);
    
    if is_sloppy {
        array_resize(*thread_counters, thread_count, true); // init to 0
        array_resize(*thread_locks, thread_count, false);
        for * thread_locks pthread_mutex_init(it, null);

        array_resize(*thread_worker_sloppy_args, thread_count, false);
        for * thread_worker_sloppy_args {
            using it;
            thread_counter = *thread_counters[it_index];
            thread_lock = *thread_locks[it_index];
        }
    }

    thread_worker_func : (*void) -> (*void) #c_call = ifx !is_sloppy ThreadWorker else ThreadWorkerSloppy;

    // start the clock
    stopwatch : Stopwatch;
    StartStopwatch(*stopwatch);

    // create threads
    for * threads thread_ids[it_index] = pthread_create(it, null, thread_worker_func,
        ifx !is_sloppy null else *thread_worker_sloppy_args[it_index]);

    // join threads
    for thread : threads pthread_join(thread, null);

    EndStopwatch(*stopwatch);
    
    print("Final counter: %\n", GetCounter());
    print("Elapsed time: % nsec\n", stopwatch.elapsed_time_nsec);
}
