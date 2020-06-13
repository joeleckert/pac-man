
#include <windows.h>
#include "timer.h"

//------------------------------------------------------------------------------

#define MICROSECONDS_PER_SECOND 1000000

//------------------------------------------------------------------------------

static LARGE_INTEGER frequency;
static LARGE_INTEGER startTime;
static LARGE_INTEGER endTime;

//------------------------------------------------------------------------------

void InitTimer()
{
	QueryPerformanceFrequency(&frequency);
	QueryPerformanceCounter(&startTime);
}

//------------------------------------------------------------------------------

void ResetTimer()
{
	startTime = endTime;
}

//------------------------------------------------------------------------------

unsigned long GetMicroseconds()
{
	QueryPerformanceCounter(&endTime);

	LONGLONG result = endTime.QuadPart - startTime.QuadPart;
	result *= MICROSECONDS_PER_SECOND;
	result /= frequency.QuadPart;
	return (unsigned long)result;
}

//------------------------------------------------------------------------------
