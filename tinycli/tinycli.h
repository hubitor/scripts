#ifndef _TINYCLI_H
#define _TINYCLI_H
#include <stdlib.h>
/*** ERRORS ***/
#define ECMD_LEN 1
#define ECMD_FORK 2
#define EARGC_MAX 3
#define ECMD_EMPTY 4
#define ECMD_EXEC 5
/*** TYPES ***/
struct {
	char *T;
	char **argv;
	unsigned char argc;
} CMD = {
	.T = NULL,
	.argv = NULL,
	.argc = 0
};
/*** CONST ***/
#define ARGC_MAX 20
#define CMD_LEN_MAX 500
/*** MACROS ***/
#define new_CMD malloc(sizeof(_CMD))
#define CMD_EXIT(s) (/*strncmp(s, "quit", 5) == 0 || */strncmp(s, "exit", 5) == 0)
/*** GLOBAL VARS ***/
char STATUS = 0; //errors go here
const char null = '\0';
const char *USER = &null;
const char *HOME = &null;
int CHILD_STATUS = 0; //the exit status of last child
pid_t CHILD_PID = 0;
char getchar_break = 0;
/*** FUNCTIONS ***/
void signal_handler(int signal);
void proc_stdin();
#endif//_TINYCLI_H
