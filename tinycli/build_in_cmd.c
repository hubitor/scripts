#include <string.h>
#include <stdlib.h>
#include <unistd.h>
//#include "tinycli.h"
#include "build_in_cmd.h"

extern int CHILD_STATUS;
extern char* HOME;
extern struct {
	char *T;
	char **argv;
	unsigned char argc;
} CMD;

void execCd();

unsigned char isBuildInCMD() {
	return (strcmp(CMD.T, "cd") == 0);
}
void execBuildInCMD() {
	if(strcmp(CMD.T, "cd") == 0)
		execCd();
}
inline void execCd() {
	if(CMD.argv[1] && CMD.argv[1][0] != '~') {// just '~' supported without more strings
		CHILD_STATUS = chdir(CMD.argv[1]);
	} else if (!CMD.argv[1]) {
		CHILD_STATUS = chdir(HOME);
	} else {
		char* arg = malloc((strlen(HOME) + strlen(CMD.argv[1]))*sizeof(char));
		strcpy(arg, HOME);
		strcat(arg, CMD.argv[1] + 1 );
		CHILD_STATUS = chdir(arg);
		free(arg);
	}
}
