#!/usr/bin/env php
<?php
/**
 * routename_auto_converter - ソース中のルーティング名を自動一括変換してくれるマシーン (PHP版)
 *
 * 20 Aug 2010, by tozuka@tejimaya.com
 * 13 Oct 2010, rewritten in PHP
 */

if ($argc < 3) {
  echo "usage: $0 <app_root> <app_name>";
  exit;
}

$working_dir = getcwd();
$app_root = $argv[1];
$app_name = $argv[2];

# $routing_data_path     = $app_root.'/.'.$app_name.'_app_routes.dat';
$converter_sed_script_path = $app_root.'/.'.$app_name.'_routename_converter.sed';
$fp = fopen($converter_sed_script_path, 'w');

/*
 * "symfony app:routes app名" からルート名一覧を取ってくる
 *
 *   methods, pattern は detail にも含まれるので割愛。
 *    - route_name ... ['Name']
 *    - methods ...... ['Requirements']['sf_method']
 *    - pattern ...... ['Pattern']
 */
function app_routes()
{
  global $app_root, $app_name;
  exec($app_root.'/symfony app:routes '.$app_name, $output, $retv);

  array_splice($output, 0, 2);

  $routes = array();
  foreach ($output as $line) {
    $route_name_ends_at = strpos($line, ' ');
    $route_name = substr($line, 0, $route_name_ends_at);

  # $method_ends_at = strpos($line, '/', $route_name_ends_at);
  # $methods = explode(', ', trim(substr($line, $route_name_ends_at, $method_ends_at-$route_name_ends_at)));

  # $pattern = substr($line, $method_ends_at);
  # printf("(%s (%s) \"%s\")\n", $route_name, join(' ',$methods), $pattern);

    $routes[] = array('route_name' => $route_name);
  }
  return $routes;
}

/*
 * "symfony app:routes app名 ルート名" からルート個別の詳細情報を取ってくる
 */
function app_routes_detail($route_name)
{
  global $app_root, $app_name;
  exec($app_root.'/symfony app:routes '.$app_name.' '.$route_name, $output, $retv);

  array_shift($output);

  $detail = array();
  foreach ($output as $line) {
    if (' ' !== $line[0]) {
      $value_at = strpos($line,' ',1);
      $attr = rtrim(substr($line, 0, $value_at));
    }
    $value = ltrim(substr($line, $value_at));

    $colon = strpos($value,': ');
    if (false !== $colon) {
      $key = substr($value, 0, $colon);
      $value = trim(substr($value, $colon+2), "'");

      if (!isset($detail[$attr])) $detail[$attr] = array();
      $detail[$attr][$key] = $value;
    } else {
      $detail[$attr] = $value;
    }
  }

  return $detail;
}

# (define details (map (lambda (x) (app-routes-detail (car x))) (app_routes)))
$visited = array();

fwrite($fp, "/include_partial/b\n"); # skip (until the end of sed script) if "include_partial"

foreach (app_routes() as $route) {
  $route_name = $route['route_name'];
  $detail = app_routes_detail($route_name);

  if (!isset($detail['Defaults']) || !isset($detail['Defaults']['module']) || !isset($detail['Defaults']['action'])) continue;
  $module_action = $detail['Defaults']['module'].'/'.$detail['Defaults']['action'];

  if (isset($detail['Requirements'])) {# && isset($detail['Requirements']['sf_method']))
    $conds = array();
    foreach (array_keys($detail['Requirements']) as $req) {
      if ('sf_method' === $req) continue;
      $conds[] = $req.'=';
    }
    # printf("> %s + %s\n", $detail['Name'], join(',',array_keys($requirements)));
    $sed = sprintf("/\\(%s\\)/s|'%s\\?|'@%s\\?|g", join('\|',$conds), $module_action, $route_name);
  } else {
    # printf("> %s\n", $detail['Name']);
    $sed = sprintf("s|'%s'|'@%s'|g", $module_action, $route_name);
  }

  $sed .= "\n";
  echo $sed;
  fwrite($fp, $sed);
}
fclose($fp);

#passthru("cat -n $converter_sed_script_path");

$routing_name_inplace_converter = 'sed -f '.$converter_sed_script_path.' -i ';
# $routing_name_inplace_converter = 'sh sed-i.sh '.$converter_script_path;

$cmd = 'find '. $app_root.'/apps '
              . $app_root.'/plugins '
              . '-type f '
              . '-name \*.php '
              . '-path \*'.$app_name.'\* -not -path \*/test/\* '
              . '-exec echo '.$routing_name_inplace_converter.' {} \;';

passthru($cmd);
