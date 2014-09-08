#include <stdlib.h>
#include "file.h"
#include <assert.h>
struct fifo *fifo_create()
{
	struct fifo *f = malloc(sizeof(*f));
	f->F = NULL;
	f->L = NULL;
	return f;
}
void fifo_shift(struct fifo *f, void *val)
{
	struct node *el = malloc(sizeof(*el));
	el->val = val;
	if(fifo_empty(f)) {
		f->F = f->L = el;
		el->next =  NULL;
	} else {
		f->L->next = el;
	        f->L =  el;
	}
}
void *fifo_unshift(struct fifo *f)
{
	assert(!fifo_empty(f));
	struct node *el = f->F;
	if(el->next != NULL)
		f->F = el->next;
	else
		f->L = f->F = NULL;
	void *val = el->val;
	free(el);
	return val;
}
unsigned fifo_empty(const struct fifo *f)
{
	return (f->L == NULL) || (f->F == NULL);
}
