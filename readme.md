# The problem

On a simple two-commit pipeline with parallelism of constant:2, files seem to *sometimes* duplicate across worker pods. It's always one pod getting 4 files and one pod getting 2 files, the one with 4 gets a couple of duplicates either from itself or from the 2-file pod.

Pachyderm version:
```
pachctl             1.5.0-RC1
pachd               1.5.0-RC1
```

Kubernetes version:
```
Client Version: version.Info{Major:"1", Minor:"6", GitVersion:"v1.6.2", GitCommit:"477efc3cbe6a7effca06bd1452fa356e2201e1ee", GitTreeState:"clean", BuildDate:"2017-04-19T20:33:11Z", GoVersion:"go1.7.5", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"6", GitVersion:"v1.6.4", GitCommit:"d6f433224538d4f9ca2f7ae19b252e6fcb66a3ae", GitTreeState:"clean", BuildDate:"2017-05-19T18:33:17Z", GoVersion:"go1.7.5", Compiler:"gc", Platform:"linux/amd64"}
```

```$ ./script.sh 
+ INPUT=0e2f72f5-input
+ pachctl create-repo 0e2f72f5-input
+ pachctl start-commit 0e2f72f5-input master
+ COMMIT=f37601ec89bd4b89963bb9d4c7b9556d
+ pachctl put-file 0e2f72f5-input f37601ec89bd4b89963bb9d4c7b9556d -f t-5519d656-a32c-4955-bd1a-36acdc245fc4/text
+ pachctl put-file 0e2f72f5-input f37601ec89bd4b89963bb9d4c7b9556d -f t-6517fe08-2871-438b-a3ec-a7d018dbc5c4/text
+ pachctl finish-commit 0e2f72f5-input f37601ec89bd4b89963bb9d4c7b9556d
+ pachctl start-commit 0e2f72f5-input master
+ COMMIT=350fcb72342c4e24acac59f81832efc1
+ pachctl put-file 0e2f72f5-input 350fcb72342c4e24acac59f81832efc1 -f t-d24f3126-68f5-4b64-8d01-8bafbc6e7c25/text
+ pachctl put-file 0e2f72f5-input 350fcb72342c4e24acac59f81832efc1 -f t-d7c22d30-31ad-449c-8d0a-d36942ef6715/text
+ pachctl finish-commit 0e2f72f5-input 350fcb72342c4e24acac59f81832efc1
+ pachctl list-repo
NAME                CREATED             SIZE                
0e2f72f5-input      1 seconds ago       24 B                
+ pachctl create-pipeline -f pipeline.json
+ echo done creating pipelines, waiting 10s for spinup
done creating pipelines, waiting 10s for spinup
+ sleep 10
+ pachctl list-pipeline
NAME                INPUT               OUTPUT                   CREATED             STATE               
southclaws-test     0e2f72f5-input:/*   southclaws-test/master   10 seconds ago      running    
+ pachctl list-job
ID                                   OUTPUT COMMIT                                    STARTED       DURATION           RESTART PROGRESS STATE            
467ccb25-dec9-479b-b42b-69d2e89811f4 southclaws-test/7db8fd8df83e4ed0901c626820cfaccf 6 seconds ago Less than a second 0       4 / 4    success 
bb3561d8-6fc2-491f-a003-4402abcf6f96 southclaws-test/a76616d26c47410eac2c3c43ef775f70 7 seconds ago Less than a second 0       2 / 2    success 
+ pachctl list-job
+ + grep -cut
 -c-36
+ pachctl get-logs --job=467ccb25-dec9-479b-b42b-69d2e89811f4
+ grep /pfs/in/t-
+ grep -v text
2017/06/29 16:28:11 /pfs/in/t-6517fe08-2871-438b-a3ec-a7d018dbc5c4 (d:true) (e:<nil>)
2017/06/29 16:28:11 /pfs/in/t-d24f3126-68f5-4b64-8d01-8bafbc6e7c25 (d:true) (e:<nil>)
2017/06/29 16:28:12 /pfs/in/t-d7c22d30-31ad-449c-8d0a-d36942ef6715 (d:true) (e:<nil>)
+ pachctl get-logs --job=bb3561d8-6fc2-491f-a003-4402abcf6f96
+ + grepgrep -v /pfs/in/t- text

2017/06/29 16:28:11 /pfs/in/t-5519d656-a32c-4955-bd1a-36acdc245fc4 (d:true) (e:<nil>)
2017/06/29 16:28:11 /pfs/in/t-6517fe08-2871-438b-a3ec-a7d018dbc5c4 (d:true) (e:<nil>)```

`pfs/in/t-6517fe08-2871-438b-a3ec-a7d018dbc5c4 (d:true) (e:<nil>)` <- should not be here!
`pfs/in/t-d24f3126-68f5-4b64-8d01-8bafbc6e7c25 (d:true) (e:<nil>)` <- perfectly fine
`pfs/in/t-d7c22d30-31ad-449c-8d0a-d36942ef6715 (d:true) (e:<nil>)` <- perfectly fine
 
`pfs/in/t-5519d656-a32c-4955-bd1a-36acdc245fc4 (d:true) (e:<nil>)` <- perfectly fine
`pfs/in/t-6517fe08-2871-438b-a3ec-a7d018dbc5c4 (d:true) (e:<nil>)` <- perfectly fine
