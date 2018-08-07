#!/usr/bin/env bash
set -e

# run a conformance test for all CWL descriptions

for i in $(find workflows -name "*.cwl"); do
 echo "Testing: ${i}"
 cwltool --validate ${i}
done
