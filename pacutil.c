#include <glib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define pacman_logfile "/var/log/pacman.log"

FILE *f_pacman_log = NULL;

void print_pkgs(GHashTable *);

int main()
{
	FILE *f_pacman_log = fopen(pacman_logfile, "r");
	if (!f_pacman_log) {
		perror("Error opening log file");
		exit(1);
	}
	size_t buf_size = 200;
	char *buf = malloc(sizeof(char) * buf_size);
	GHashTable *pkgs =
	    g_hash_table_new_full(g_str_hash, g_str_equal, free, NULL);
	while (getline(&buf, &buf_size, f_pacman_log) != -1) {
		char f4[20], f5[100];
		if (sscanf(buf, "[%*s %*s [%*s %20s %100s", f4, f5) != 2)
			continue;
		if (strcmp(f4, "installed") == 0) {
			g_hash_table_add(pkgs, strdup(f5));
		} else if (strcmp(f4, "removed") == 0) {
			g_hash_table_remove(pkgs, f5);
		}
	}
	print_pkgs(pkgs);
	free(buf);
}

void print_pkgs(GHashTable *pkgs)
{
	GHashTableIter it;
	gpointer k, v;

	g_hash_table_iter_init(&it, pkgs);
	while (g_hash_table_iter_next(&it, &k, &v)) {
		puts(k);
	}
}
