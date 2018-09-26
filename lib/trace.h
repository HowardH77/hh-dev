/*  Name:        trace.h
 *  Description: trace macros.  Note: Trace output is written to stderr.
 */

#ifndef TRACE_H

#ifdef DTRACE
#define TRACE(var1,fmt1) fprintf(stderr, "TRACE: " #var1 "=" fmt1 "\n", var1)
#define TRACE2(var1,fmt1, var2,fmt2) fprintf(stderr, "TRACE: " #var1 "=" fmt1 ", " #var2 "=" fmt2 "\n", var1, var2)
#else
#define TRACE(var1,fmt1)
#define TRACE2(var1,fmt1, var2,fmt2)
#endif

#define TRACE_H 1
#endif

/*
:!a.out 2>/usr/tmp/trace.stderr | vip /usr/tmp/trace.stderr
*/
