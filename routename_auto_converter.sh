#!/bin/sh
#
# routename_auto_converter - ソース中のルーティング名を自動一括変換してくれるマシーン
#
# 20 Aug 2010, by tozuka@tejimaya.com
#
# ./symfony のほか sed, awk, find を使っています
#
if [ x$1 = x ]; then
  echo "usage: $0 <app_name>"
  exit
fi

APP=$1  ## mobile_frontend

ROUTING_DATA=${APP}_app_routes.dat
ROUTING_NAME_CONVERTER=${APP}_app_routes.sed

# symfony app:routes からルーティング情報抽出。
# アプリ1つ(mobile_frontend等)につき1時間前後かかる
if [ ! -e $ROUTING_DATA ]; then
  awk -f routename_auto_converter_1.awk -v app=${APP} > $ROUTING_DATA
fi

# ルーティング情報から一括変換用sedスクリプトを生成
awk -f routename_auto_converter_2.awk $ROUTING_DATA > $ROUTING_NAME_CONVERTER

# 適用
#   ./apps, ./plugins 以下にある ../mobile_frontend/.../???.php のような名前のファイルのみに対し
#  上で作ったsedスクリプトを適用し、インプレイスで置換する。
#  sed が -i オプションに対応してないと駄目です
find apps plugins -type f -name \*.php -path \*${APP}\* -not -path \*/test/\* -exec sed -f $ROUTING_NAME_CONVERTER {} -i \;
# find apps plugins -type f -name \*.php -path \*${APP}\* -not -path \*/test/\* -exec sh inplace_conv.sh {} -f $ROUTING_NAME_CONVERTER \;
