#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

int main(void) {
    printf("Task Manager Started (PID: %d)\n", getpid());

    /* Fork BOTH monitors first so they run concurrently — that's the
     * whole point of being a multi-process task manager. */

    pid_t pid1 = fork();
    if (pid1 < 0) {
        perror("Fork failed for CPU Monitor");
        return 1;
    } else if (pid1 == 0) {
        printf("\n[CPU Monitor] Started (PID: %d, Parent PID: %d)\n", getpid(), getppid());
        char *args[] = {"mpstat", "1", "3", NULL}; /* 3 samples, 1s apart */
        execvp(args[0], args);
        perror("execvp failed for mpstat");
        _exit(127);
    }

    pid_t pid2 = fork();
    if (pid2 < 0) {
        perror("Fork failed for Process Monitor");
        /* Reap the already-started CPU monitor before bailing out. */
        waitpid(pid1, NULL, 0);
        return 1;
    } else if (pid2 == 0) {
        printf("\n[Process Monitor] Started (PID: %d, Parent PID: %d)\n", getpid(), getppid());
        char *args[] = {"ps", "-e", "-f", NULL};
        execvp(args[0], args);
        perror("execvp failed for ps");
        _exit(127);
    }

    /* Parent waits for both children. waitpid returns -1/ECHILD if a
     * child was already reaped by a stray SIGCHLD handler, so loop
     * until both have been collected. */
    int status;
    while (waitpid(pid1, &status, 0) < 0) { /* keep waiting */ }
    while (waitpid(pid2, &status, 0) < 0) { /* keep waiting */ }

    printf("\nTask Manager Exiting.\n");
    return 0;
}

