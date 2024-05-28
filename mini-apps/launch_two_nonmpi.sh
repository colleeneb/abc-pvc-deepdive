#!/bin/bash                                                                                                                                                                                                                          

if [ "$#" -ne 1 ]
then
    echo "Need to provide 1 input, the name of the executable."
    echo "Usage: $0 name_of_exe"
    echo "  This launches the same exe twice, once on tile 0.0"
    echo "  and once on tile 0.1 so they run at roughly the same time"
  exit 1
fi

executable=$1

if [ -x "$(command -v $executable)" ]; then
    ZE_AFFINITY_MASK=0.0 $executable &
    ZE_AFFINITY_MASK=0.1 $executable &
else
    echo "$executable not found"
fi
wait
