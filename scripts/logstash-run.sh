#!/bin/bash
set -ex

export PATH=$BUILD_DIR/gradle/bin:$PATH

SERVICE_URL="http://integration:9200"

wait_for_es() {
  count=120
  while ! curl -s $SERVICE_URL >/dev/null && [[ $count -ne 0 ]]; do
    count=$(( $count - 1 ))
    [[ $count -eq 0 ]] && exit 1
    sleep 1
  done
  echo $(curl -s $SERVICE_URL | python -c "import sys, json; print(json.load(sys.stdin)['version']['number'])")
}

echo "Waiting for cluster to respond..."
VERSION=$(wait_for_es)
echo "Integration test cluster $VERSION is Up!"
bundle exec rspec -fd --tag integration --tag update_tests:painless --tag version:$VERSION spec/integration