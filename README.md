# MySQL サーバー構築の自動化

Ansibleを使用して、AlmaLinux環境におけるMySQLサーバーの構築と最適化手順を自動化するプロジェクトです。
サーバーのメモリスペック（1GB / 2GB / 4GB）に応じた最適なMySQL設定を自動的に適用します。

## クイックスタート (導入手順)

はじめてサーバーに導入する際は、まず `git` をインストールし、このプロジェクトをサーバーにダウンロード（クローン）する必要があります。

```bash
# 1. git のインストール (root権限で実行)
dnf install -y git

# 2. プロジェクトのダウンロードと移動
git clone https://github.com/your-repo/ansible-mysql-server.git
cd ansible-mysql-server/mysql-project

# 3. 設定ファイルの準備 (設定の詳細は下の「設定方法」を参照)
cp group_vars/secret_sample.yml group_vars/secret.yml
vi group_vars/secret.yml
vi group_vars/all.yml

# 4. セットアップの実行 (AnsibleのインストールからPlaybookの適用まで完了します)
chmod +x setup.sh
./setup.sh
```

## 設定方法

実行前に、以下の設定を確認・変更してください。

### 1. 機密情報の設定 (パスワード等)
`group_vars/secret.yml` にMySQLのパスワード等の認証情報を設定します。

- `mysql_root_password`: MySQLのルートパスワード
- `mysql_app_database`: 作成するデータベース名
- `mysql_app_user`: アプリケーション用データベースユーザー名
- `mysql_app_password`: アプリケーション用ユーザーのパスワード
- `mysql_maintainer_user`: メンテナンス用ユーザー名
- `mysql_maintainer_password`: メンテナンス用パスワード

### 2. 環境設定 (スペック)
`group_vars/all.yml` を編集します。

- `server_memory_size`: 実際のサーバースペック (`"1GB"`, `"2GB"`, `"4GB"` から選択)

## 自動化内容

1. MySQLサーバーと必要なモジュール（PyMySQL）のインストール
2. サーバースペックに基づく設定チューニング (`innodb_buffer_pool_size`, `max_connections` 等)
3. MySQLのrootパスワード初期設定
4. アプリケーション用データベース、およびアプリ用・メンテ用ユーザーの作成（全てのDBへの権限付与）
5. クラウドFW側の利用を前提とした OS ファイアウォール (`firewalld`) の無効化

---

## 高度な使い方: 手動実行コマンド

`setup.sh` を使用せずに一つずつ手動で実行する場合の手順です。

```bash
# 1. Ansibleのインストール
dnf install -y ansible-core

# 2. 依存コレクションのインストール
ansible-galaxy collection install -r requirements.yml

# 3. Playbookの実行
ansible-playbook -i hosts site.yml
```
