#include "fsm_gensig.h"
#include <stdio.h>

void dump_ctx(ctx_t ctx)
{
  printf("start=%d s=%d k=%d\n", ctx.start, ctx.s, ctx.k);
}

void fsm_gensig(ctx_t *ctx)
{
  static int k;
  static enum { E0, E1 } state = E0;
  static int _init = 1;
  if ( _init ) {
    ctx->s=0;
    _init=0; 
    }
  switch ( state ) {
    case E0:
      if ( ctx->start==1 ) {
        k=0;
        ctx->s=1;
        state = E1;
        }
      break;
    case E1:
      if ( k<4 ) {
        k=k+1;
        }
      else if ( k==4 ) {
        ctx->s=0;
        state = E0;
        }
      break;
    }
  ctx->k = k;
};
