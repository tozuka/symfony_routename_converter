BEGIN {
  FS = "\t"
}

{
  module_and_action = $1
  route_name = $2

  if (table[module_and_action]) next
  table[module_and_action] = route_name
}

END {
  printf("/include_partial/b\n"); # skip (until the end of sed script) if "include_partial"
  for (module_and_action in table) {
    route_name = table[module_and_action]
    printf("s|'%s\\([\\?']\\)|'@%s\\1|g\n", module_and_action, route_name)
  }
}
