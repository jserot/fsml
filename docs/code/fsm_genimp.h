#ifndef _fsm_gensig_h
#define _fsm_gensig_h

#include "fsml.h"

typedef struct {
  IN int start;
 OUT int s;
     int k;
} ctx_t;

void dump_ctx(ctx_t ctx);
void fsm_gensig(ctx_t *ctx);

#endif
