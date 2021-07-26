#include <iostream>
#include "path_tracker.h"

int main()
{
    int path[2] = {0, 0};
    PathTracker pt = PathTracker(path, 1);
    pt.summary();

    return 0;
}
