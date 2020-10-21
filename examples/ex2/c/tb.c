#include "genimp.h"

int main(int argc, char **argv)
{
  ctx_t ctx = { 0, 0, 0 }; 
  dump_ctx(ctx);
  fsm_gensig(&ctx);
  dump_ctx(ctx);
  ctx.start = 1;
  fsm_gensig(&ctx);
  dump_ctx(ctx);
  ctx.start = 0;
  for ( int i=0; i<6; i++ ) {
    fsm_gensig(&ctx);
    dump_ctx(ctx);
    }
}
