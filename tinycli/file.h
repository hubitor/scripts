//struct val {
//	unsigned pos, len;
//};
struct node {
	void *val;
	struct node *next;
};
struct fifo {
	struct node *F, *L;
};

struct fifo *fifo_create();
void fifo_shift(struct fifo *f, void* val);
void *fifo_unshift(struct fifo *f);
unsigned fifo_empty(const struct fifo *f);
