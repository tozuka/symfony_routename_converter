#!/bin/bash
#
# routename_auto_converter - ソース中のルーティング名を自動一括変換してくれるマシーン
#
# 20 Aug 2010, by tozuka@tejimaya.com
#
# ./symfony のほか sed, awk, find を使っています
#
if [ x$2 = x ]; then
  echo "usage: $0 <app_root> <app_name>"
  exit
fi

WORKDIR=`pwd`
APP_ROOT=$1
APP_NAME=$2  ## eg. mobile_frontend

echo $WORKDIR $APP_ROOT $APP_NAME

ROUTING_DATA=${APP_ROOT}/.${APP_NAME}_app_routes.dat
CONVERTER_SCRIPT=${APP_ROOT}/.${APP_NAME}_app_routes.sed

ROUTING_NAME_INPLACE_CONVERTER="sed -f ${CONVERTER_SCRIPT} -i "
#ROUTING_NAME_INPLACE_CONVERTER="sh sed-i.sh ${CONVERTER_SCRIPT} "

pushd . > /dev/null
cd $APP_ROOT
rm -f .${APP_NAME}_app_routes.*

# symfony app:routes からルーティング情報抽出。
# アプリ1つ(mobile_frontend等)につき1時間前後かかる
if [ ! -e $ROUTING_DATA ]; then
  awk -f ${WORKDIR}/routename_auto_converter_1.awk -v app=$APP_NAME > $ROUTING_DATA
fi

# ルーティング情報から一括変換用sedスクリプトを生成
if [ ! -e $CONVERTER_SCRIPT ]; then
  awk -f ${WORKDIR}/routename_auto_converter_2.awk $ROUTING_DATA > $CONVERTER_SCRIPT
fi


exit

# 適用
#   ./apps, ./plugins 以下にある ../mobile_frontend/.../???.php のような名前のファイルのみに対し
#  上で作ったsedスクリプトを適用し、インプレイスで置換する。
#  sed が -i オプションに対応してないと駄目です
find ${APP_ROOT}/apps ${APP_ROOT}/plugins \
     -type f -name \*.php -path \*${APP_NAME}\* -not -path \*/test/\* \
     -exec echo $ROUTING_NAME_INPLACE_CONVERTER {} \;
     #-exec $ROUTING_NAME_INPLACE_CONVERTER {} \;

# rm -f .${APP_NAME}_app_routes.*
popd

