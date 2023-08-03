## このリポジトリは？

以下を実施するためのもの。

- ECSでコンテナーを動かす
- AWSの環境はterraformで作る
- GitHubActionsでCI/CD。ECRにPUSH、ローリングアップデート

## AWSで構築する環境

Pulurarithで構築。



## 参考記事

タスク定義の作り方

aws ecs describe-task-definition --task-definition yamada-ecs-task-definition | \
  jq '.taskDefinition | del (.taskDefinitionArn, .revision, .status, .requiresAttributes, .compatibilities)' > task-def.json
