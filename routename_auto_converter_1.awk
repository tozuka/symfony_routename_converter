BEGIN {
  OFS = "\t"

  if (!app) exit;

  M = retrieve_route_list(app)
  for (id=0; id<M; id++) {
    route_name = route_names[id]
    method = methods[id]
    pattern = patterns[id]

    module_and_action = retrieve_route_detail(app,route_name)

    print module_and_action, route_name, method, pattern
  }
  exit
}

function retrieve_route_detail(app,route_name,   cmd,action,module)
{
  action = module = ""
  cmd = "./symfony app:routes " app " " route_name " > retriever.tmp"
  stat = system(cmd)

  while (getline < "retriever.tmp") { ## 一旦ファイルに書き出すのは画面着色コード抜きのリストが欲しいから
    if (/Defaults/) {
      while (1) {
        if (/action:/) {
          action = $0
          gsub(/^.*: '/,"",action); gsub(/'.*$/,"",action)
        } else if (/module:/) {
          module = $0
          gsub(/^.*: '/,"",module); gsub(/'.*$/,"",module)
        }
        getline < "retriever.tmp"
        if (/^[A-Z]/) break
      }
      break
    }
  }
  close("retriever.tmp")
  return module "/" action
}

function retrieve_route_list(app,   cmd,route_id,route_name,method,pattern)
{
  route_id = 0
  cmd = "./symfony app:routes " app " > list_retriever.tmp"
  system(cmd)
  while (getline < "list_retriever.tmp") {
    if (/^>> app/) continue
    if (/^Name/) continue;

    if (route_id == 0) {
      name_from    = 1
      method_from  = index($0,$2);
      pattern_from = index($0,"/")
    }

    route_name = substr($0, name_from, method_from - name_from)
    method = substr($0, method_from, pattern_from - method_from)
    pattern = substr($0, pattern_from)
    # rtrim
    gsub(/[ \t]+$/,"",route_name)
    gsub(/[ \t]+$/,"",method)
    gsub(/[ \t]+$/,"",pattern)

    route_names[route_id] = route_name
    methods[route_id] = method
    patterns[route_id] = pattern

    route_id++
  }
  close("list_retriever.tmp")
  return route_id
}
