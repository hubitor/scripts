#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <signal.h>
#include <unistd.h>
#include <string.h>
#include "tinycli.h"
#include "build_in_cmd.h"
/*** HERE WE GO! ***/
int main (int argc, char *argv[], char *arge[]) {
	extern char *get_current_dir_name();
	for(unsigned char i = 0, c = 0; c < 2 && arge[i]; i++) {
		if(strncmp("USER=", arge[i], 5) == 0){
			USER = arge[i] + 5;
			c++;
		} else if(strncmp("HOME=", arge[i], 5) == 0){
			HOME = arge[i] + 5;
			c++;
		}
	}
#ifdef DEBUG
	printf("DEBUG: HOME: %s\n", HOME);
	printf("DEBUG: USER: %s\n", USER);
#endif
	struct sigaction sa;
//	memset (&sa, 0, sizeof (sa));
	sigemptyset(&sa.sa_mask);
	sa.sa_handler = &signal_handler;
	sigaction (SIGINT, &sa, NULL);
//	printf("%s:: Saisir a commnad to exec\n", *argv);
	while (1) {
		STATUS = 0; //init status to 0 every new cmd ??
		// free CMD elements
		if(CMD.T) free(CMD.T);
		if(CMD.argv){
			free(CMD.argv);
		}
		// init CMD elements
		CMD.T = malloc(CMD_LEN_MAX * sizeof(char));
		CMD.argv = malloc(ARGC_MAX * sizeof(char *));
		CMD.argc = 0;
		CMD.T[0] = '\0'; //some errors can causd by an empty cmd
                printf("%s:%s (%d) $ ", USER,  get_current_dir_name(), CHILD_STATUS);

	        fflush(stdin);
		proc_stdin();
		if(CMD.argc < 1)
			continue;

		if (STATUS < 0) {
			fprintf(stderr, "%s:: CMD reading error (%d)). continue!\n", *argv, STATUS);
			continue;
		}
		if (CMD_EXIT(CMD.T)){
#ifdef DEBUG
			printf("DEBUG: EXIT CMD(%s)\n", CMD.T);
#endif
			break;
		}

		if(isBuildInCMD()) {
			execBuildInCMD();
			continue;
		}
		int Pid = fork();
		if(Pid == -1) {
			fprintf(stderr, "%s:: CMD fork error (%d)). continue!\n", *argv, -ECMD_FORK);
			continue;
		} else if(Pid == 0){
#ifdef DEBUG
			printf("DEBUG: CMD PATH(%s), CMD:ARGS: ", CMD.T);
			for(int i = 0; i < CMD.argc; i++)
				printf("%s ", CMD.argv[i]);
			puts("");
#endif
			execvp(CMD.T, CMD.argv);
			fprintf(stderr, "%s:: CMD exec error (%d)). return!\n", *argv, -ECMD_EXEC);
			return -1;
		} else {
			CHILD_PID = Pid;
			int ETAT;
			wait(&ETAT);
			CHILD_PID = 0;
			CHILD_STATUS = WEXITSTATUS (ETAT);
		}
	}

//	puts("BYE!");
	return 0;
}
void signal_handler(int signal) {
	switch (signal) {
	case SIGINT:
		if (CHILD_PID > 0)
			kill (CHILD_PID, SIGINT);
		else {
			getchar_break = 1;
			puts("");
		}
	}
}
void proc_stdin() {
	// ' ` "    ;
		char c;
//		char sup_char = ' ';
		unsigned input_len = 0;
		unsigned argv_pos = 0;
		while (1) {
			if(getchar_break){
#ifdef DEBUG
				puts("DEBUG: GETCHAR_BREAK");
#endif
				CMD.argc = 0;
				getchar_break = 0;
				break;
			}
			c = getchar();
			if (c == ' ' || c == '\t' || c == '\n') {
				if(argv_pos == input_len){ // two whitespaces side by side
				        if(c == '\n')
						break;
					continue;
				}
				if(CMD.argc == ARGC_MAX){
#ifdef DEBUG
					printf("DEBUG:ERROR GETCHAR ARGC_MAX(%d)\n", CMD.argc);
#endif
					STATUS = -EARGC_MAX;
					break;
				}
				CMD.T[input_len++] = '\0';
				CMD.argv[CMD.argc++] = CMD.T + argv_pos;
#ifdef DEBUG
				printf("DEBUG: ARGV ADD(%s)\n", CMD.argv[CMD.argc - 1]);
#endif
				if(c == '\n')
					break;
				argv_pos =  input_len;
				continue;
			}
			if(input_len > CMD_LEN_MAX - 2) {
				STATUS = -ECMD_LEN;
				break;
			}
			CMD.T[input_len++] = c;
		}
		if(CMD.argc < 1)
			return;
//			STATUS = -ECMD_EMPTY;  ??
		//free extra bytes
		CMD.argv = realloc(CMD.argv, sizeof(char*) * (CMD.argc + 1));
		CMD.T = realloc(CMD.T, sizeof(char) * input_len);
		CMD.argv[CMD.argc] = NULL;
		CMD.argv[0] = strrchr(CMD.T, '/');  // get pos of last '/' on first arg
		if(!CMD.argv[0]++) CMD.argv[0] = CMD.T; // and if no '/' found, point to the beginning of the arg
#ifdef DEBUG
		puts("DEBUG: GETCHAR DONE");
#endif
}
