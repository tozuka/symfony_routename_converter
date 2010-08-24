BEGIN {
  FS = "\t"
}

{
  module_and_action = $1
  route_name = $2

  table[module_and_action] = route_name
  count[module_and_action]++;
}

END {
  printf("/include_partial/b\n"); # skip (until the end of sed script) if "include_partial"
  for (module_and_action in table) {
    if (count[module_and_action] > 1) continue
    route_name = table[module_and_action]
    printf("s|'%s\\([\\?']\\)|'@%s\\1|g\n", module_and_action, route_name)
  }
}
