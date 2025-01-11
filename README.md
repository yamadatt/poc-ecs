## このリポジトリは？

以下を目的とするためのもの。

- ECSでコンテナーを動かすことを体感する
- ECSの検証を手軽にする

## やってること

- AWSの環境はterraformで作る
- GitHubActionsでCI/CD
  - ECRにPUSH
  - ECSタスクを更新（ローリングアップデート）
- ~~EFSをマウントするので、ファイルを永続化できるようにしている（EFSのIDは手で変更すること）~~　EFSIDをタスク定義にうまいこと渡せないので、やめた
- ECS EXECに対応しているので、タスクにアタッチできる

##　使い方

terraformで環境構築



## 注意事項

GitHubActionsでのデプロイに時間がかかることに注意。

だいたい3分ちょっとぐらいかかる。

## 参考

### タスク定義

タスク定義追加。タスクを定義したjsonファイルを使用する。


```bash
aws ecs register-task-definition --cli-input-json file://task-def.json
```
### ECSデプロイ

```bash
aws ecs update-service --cluster yamada-ecs-cluster --service yamada-ecs-service --task-definition yamada-ecs-task-definition
```


タスク定義jsonの出力。

```
aws ecs describe-task-definition --task-definition yamada-ecs-task-definition | \
  jq '.taskDefinition | del (.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities)' > task-def.json
```

ECSのサービスがEXECに対応しているかを確認。

```
aws ecs describe-services \
--cluster yamada-ecs-cluster \
--services yamada-ecs-service \
--query 'services[0].enableExecuteCommand'
```

### タスク

タスクのリストを出力

```
aws ecs list-tasks \
--cluster yamada-ecs-cluster \
--service yamada-ecs-service
```

タスクがEXECに対応しているか確認。

```
aws ecs describe-tasks \
--cluster yamada-ecs-cluster \
--tasks cdc027ce890d40b3a51370fb5fbbc0ef \
--query 'tasks[0].enableExecuteCommand'
```

タスクにEXECする。

```
aws ecs execute-command \
--cluster yamada-ecs-cluster \
--task 255d419838dc4b959b70f8e4fc154c1c \
--container golang-helloworld \
--interactive \
--command /bin/sh
```
