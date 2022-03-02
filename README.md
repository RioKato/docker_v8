# docker_v8

## cheatsheet
### source code
```c
#include "src/base/debug/stack_trace.h"

printf("%s:%d, %s\n", __FILE__, __LINE__, __func__); v8::base::debug::StackTrace st; st.Print();

// Handle<Object> value;
value->Print();

// Handle<JSReceiver> receiver;
receiver->Print();
receiver->map().Print()

```

### debugger
```js
// prepare feedback vector
%PrepareFunctionForOptimization(fun);

fun();

// optimize fnction
%OptimizeFunctionOnNextCall(fun);

fun()

%DebugPrint(hoo);
%SystemBreak();
```
## chrome
```console
root@pentest:/opt/google/chrome# ./chrome --js-flags '--allow-natives-syntax' --headless --no-sandbox --disable-gpu http://www.google.com
```
