#include "fsm_pgcd.h"

int main(int argc, char **argv)
{
  ctx_t ctx = { 0, 36, 24, 0, 0 }; 
  dump_ctx(ctx);
  fsm_pgcd(&ctx);
  dump_ctx(ctx);
  ctx.start = 1;
  fsm_pgcd(&ctx);
  dump_ctx(ctx);
  ctx.start = 0;
  while ( ctx.rdy != 1 ) {
    fsm_pgcd(&ctx);
    dump_ctx(ctx);
    }
}
