#!/bin/bash

rm TestResults
rm -r TestResults*

echo -e "\nTesting...\n"

if [ $# -gt 0 ]
then
    xcodebuild test -workspace 'PPOcards.xcworkspace' -scheme 'PPOcards Postgres' -destination 'platform=macOS' -only-testing:$1 -derivedDataPath DerivedData -resultBundlePath TestResults > buildResults.txt 2>&1
else
    xcodebuild test -workspace 'PPOcards.xcworkspace' -scheme 'PPOcards Postgres' -destination 'platform=macOS' -derivedDataPath DerivedData -resultBundlePath TestResults > buildResults.txt 2>&1
fi
exit_code=$?

cat buildResults.txt | tail -n 100
> buildResults.txt
./xcresults export TestResults.xcresult tests_artifacts

exit $exit_code

# allure serve tests_artifacts