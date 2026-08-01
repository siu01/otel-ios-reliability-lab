#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <time.h>

int main(void) {
    struct timespec timestamp;
    struct tm utc;
    char seconds[32];

    if (clock_gettime(CLOCK_REALTIME, &timestamp) != 0) {
        return 1;
    }
    if (gmtime_r(&timestamp.tv_sec, &utc) == NULL) {
        return 1;
    }
    if (strftime(seconds, sizeof(seconds), "%Y-%m-%dT%H:%M:%S", &utc) == 0) {
        return 1;
    }

    printf("%s.%03ldZ\n", seconds, timestamp.tv_nsec / 1000000L);
    return 0;
}
