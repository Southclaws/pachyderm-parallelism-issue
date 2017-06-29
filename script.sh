#!/bin/sh -x

# t-5519d656-a32c-4955-bd1a-36acdc245fc4
# t-6517fe08-2871-438b-a3ec-a7d018dbc5c4
# t-d24f3126-68f5-4b64-8d01-8bafbc6e7c25
# t-d7c22d30-31ad-449c-8d0a-d36942ef6715

INPUT="0e2f72f5-input"

pachctl create-repo $INPUT
COMMIT=$(pachctl start-commit $INPUT master)

pachctl put-file $INPUT $COMMIT -f t-5519d656-a32c-4955-bd1a-36acdc245fc4/text
pachctl put-file $INPUT $COMMIT -f t-6517fe08-2871-438b-a3ec-a7d018dbc5c4/text

pachctl finish-commit $INPUT $COMMIT


COMMIT=$(pachctl start-commit $INPUT master)

pachctl put-file $INPUT $COMMIT -f t-d24f3126-68f5-4b64-8d01-8bafbc6e7c25/text
pachctl put-file $INPUT $COMMIT -f t-d7c22d30-31ad-449c-8d0a-d36942ef6715/text

pachctl finish-commit $INPUT $COMMIT

pachctl list-repo

pachctl create-pipeline -f pipeline.json

echo "done creating pipelines, waiting 10s for spinup"
sleep 10

pachctl list-pipeline
pachctl list-job

for job in $(pachctl list-job | grep "-" | cut -c-36); do pachctl get-logs --job=$job | grep "/pfs/in/t-" | grep -v text; done;
