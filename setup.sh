#!/bin/bash

# エラー発生時、未定義変数の参照時、パイプライン途中のエラー時にスクリプトを即時停止する（フェイルセーフ）
set -euo pipefail

echo "================================================="
echo " MySQL + Ansible 環境セットアップを開始します "
echo "================================================="

# rootユーザー (EUIDが0) で実行されているかチェックする
if [ "$EUID" -ne 0 ]; then
    echo "[エラー] このスクリプトは管理者権限が必要です。 'sudo ./setup.sh' と実行してください。"
    exit 1
fi

# ==============================================================================
# 1. Ansibleのインストール確認とインストール
# ==============================================================================
# 'command -v' で ansible コマンドが存在するか確認し、なければインストールする
if ! command -v ansible &> /dev/null; then
    echo "Ansibleがインストールされていません。インストールを開始します..."
    dnf install -y epel-release
    dnf install -y ansible-core
else
    echo "Ansibleは既にインストールされています。"
fi

# ==============================================================================
# 2. 依存コレクションのインストール
# ==============================================================================
echo "Ansibleコレクションをインストールしています..."
ansible-galaxy collection install -r requirements.yml

# ==============================================================================
# 3. 機密情報ファイル (secret.yml) の準備確認
# ==============================================================================
if [ ! -f group_vars/secret.yml ]; then
    echo "警告: パスワード設定ファイル (group_vars/secret.yml) が見つかりません。"
    echo "サンプルの secret_sample.yml をコピーして secret.yml を自動作成します。"
    cp group_vars/secret_sample.yml group_vars/secret.yml
fi

# ==============================================================================
# 4. AlmaLinux 10 向け MySQL パッケージの事前インストール
# ==============================================================================
if [ -f /etc/os-release ] && grep -q "VERSION_ID=\"10\"" /etc/os-release; then
    echo "AlmaLinux 10 を検知しました。MySQL 9 (Innovation) 公式リポジトリとパッケージを事前にインストールします..."
    dnf install -y https://dev.mysql.com/get/mysql84-community-release-el10-2.noarch.rpm
    dnf repolist | grep mysql
    dnf install -y --disablerepo="mysql-8.4-lts-community" --enablerepo="mysql-innovation-community" mysql-community-server mysql-community-client python3-PyMySQL
fi


# ==============================================================================
# 5. Ansible Playbook の実行
# ==============================================================================
echo "Playbook (site.yml) を実行し、環境構築を開始します..."
echo "※各種設定は group_vars 内の値が使用されます。"

ansible-playbook -i hosts site.yml


echo "================================================="
echo " セットアップスクリプトが正常に完了しました！ "
echo "================================================="
