"module"() ( {
  "llvm.func"() ( {
  ^bb0(%arg0: f64):  // no predecessors
    %0 = "llvm.call"(%arg0) {callee = @llvm.sin.f64, fastmathFlags = #llvm.fastmath<>} : (f64) -> f64
    %1 = "llvm.call"(%arg0) {callee = @llvm.cos.f64, fastmathFlags = #llvm.fastmath<>} : (f64) -> f64
    %2 = "llvm.fdiv"(%0, %1) : (f64, f64) -> f64
    "llvm.return"(%2) : (f64) -> ()
  }) {linkage = 10 : i64, sym_name = "fdiv_sin_cos", type = !llvm.func<f64 (f64)>} : () -> ()
  "llvm.func"() ( {
  ^bb0(%arg0: f64):  // no predecessors
    %0 = "llvm.call"(%arg0) {callee = @llvm.sin.f64, fastmathFlags = #llvm.fastmath<>} : (f64) -> f64
    %1 = "llvm.call"(%arg0) {callee = @llvm.cos.f64, fastmathFlags = #llvm.fastmath<>} : (f64) -> f64
    %2 = "llvm.fdiv"(%0, %1) : (f64, f64) -> f64
    "llvm.return"(%2) : (f64) -> ()
  }) {linkage = 10 : i64, sym_name = "fdiv_strict_sin_strict_cos_reassoc", type = !llvm.func<f64 (f64)>} : () -> ()
  "llvm.func"() ( {
  ^bb0(%arg0: f64, %arg1: !llvm.ptr<i32>):  // no predecessors
    %0 = "llvm.call"(%arg0) {callee = @llvm.sin.f64, fastmathFlags = #llvm.fastmath<>} : (f64) -> f64
    %1 = "llvm.call"(%arg0) {callee = @llvm.cos.f64, fastmathFlags = #llvm.fastmath<>} : (f64) -> f64
    %2 = "llvm.fdiv"(%0, %1) : (f64, f64) -> f64
    "llvm.return"(%2) : (f64) -> ()
  }) {linkage = 10 : i64, sym_name = "fdiv_reassoc_sin_strict_cos_strict", type = !llvm.func<f64 (f64, ptr<i32>)>} : () -> ()
  "llvm.func"() ( {
  ^bb0(%arg0: f64):  // no predecessors
    %0 = "llvm.call"(%arg0) {callee = @llvm.sin.f64, fastmathFlags = #llvm.fastmath<>} : (f64) -> f64
    %1 = "llvm.call"(%arg0) {callee = @llvm.cos.f64, fastmathFlags = #llvm.fastmath<>} : (f64) -> f64
    %2 = "llvm.fdiv"(%0, %1) : (f64, f64) -> f64
    "llvm.return"(%2) : (f64) -> ()
  }) {linkage = 10 : i64, sym_name = "fdiv_reassoc_sin_reassoc_cos_strict", type = !llvm.func<f64 (f64)>} : () -> ()
  "llvm.func"() ( {
  ^bb0(%arg0: f64):  // no predecessors
    %0 = "llvm.call"(%arg0) {callee = @llvm.sin.f64, fastmathFlags = #llvm.fastmath<>} : (f64) -> f64
    %1 = "llvm.call"(%arg0) {callee = @llvm.cos.f64, fastmathFlags = #llvm.fastmath<>} : (f64) -> f64
    %2 = "llvm.fdiv"(%0, %1) : (f64, f64) -> f64
    "llvm.call"(%1) {callee = @use, fastmathFlags = #llvm.fastmath<>} : (f64) -> ()
    "llvm.return"(%2) : (f64) -> ()
  }) {linkage = 10 : i64, sym_name = "fdiv_sin_cos_reassoc_multiple_uses", type = !llvm.func<f64 (f64)>} : () -> ()
  "llvm.func"() ( {
  ^bb0(%arg0: f64):  // no predecessors
    %0 = "llvm.call"(%arg0) {callee = @llvm.sin.f64, fastmathFlags = #llvm.fastmath<>} : (f64) -> f64
    %1 = "llvm.call"(%arg0) {callee = @llvm.cos.f64, fastmathFlags = #llvm.fastmath<>} : (f64) -> f64
    %2 = "llvm.fdiv"(%0, %1) : (f64, f64) -> f64
    "llvm.return"(%2) : (f64) -> ()
  }) {linkage = 10 : i64, sym_name = "fdiv_sin_cos_reassoc", type = !llvm.func<f64 (f64)>} : () -> ()
  "llvm.func"() ( {
  ^bb0(%arg0: f32):  // no predecessors
    %0 = "llvm.call"(%arg0) {callee = @llvm.sin.f32, fastmathFlags = #llvm.fastmath<>} : (f32) -> f32
    %1 = "llvm.call"(%arg0) {callee = @llvm.cos.f32, fastmathFlags = #llvm.fastmath<>} : (f32) -> f32
    %2 = "llvm.fdiv"(%0, %1) : (f32, f32) -> f32
    "llvm.return"(%2) : (f32) -> ()
  }) {linkage = 10 : i64, sym_name = "fdiv_sinf_cosf_reassoc", type = !llvm.func<f32 (f32)>} : () -> ()
  "llvm.func"() ( {
  ^bb0(%arg0: f128):  // no predecessors
    %0 = "llvm.call"(%arg0) {callee = @llvm.sin.f128, fastmathFlags = #llvm.fastmath<>} : (f128) -> f128
    %1 = "llvm.call"(%arg0) {callee = @llvm.cos.f128, fastmathFlags = #llvm.fastmath<>} : (f128) -> f128
    %2 = "llvm.fdiv"(%0, %1) : (f128, f128) -> f128
    "llvm.return"(%2) : (f128) -> ()
  }) {linkage = 10 : i64, sym_name = "fdiv_sinfp128_cosfp128_reassoc", type = !llvm.func<f128 (f128)>} : () -> ()
  "llvm.func"() ( {
  }) {linkage = 10 : i64, sym_name = "llvm.sin.f64", type = !llvm.func<f64 (f64)>} : () -> ()
  "llvm.func"() ( {
  }) {linkage = 10 : i64, sym_name = "llvm.sin.f32", type = !llvm.func<f32 (f32)>} : () -> ()
  "llvm.func"() ( {
  }) {linkage = 10 : i64, sym_name = "llvm.cos.f64", type = !llvm.func<f64 (f64)>} : () -> ()
  "llvm.func"() ( {
  }) {linkage = 10 : i64, sym_name = "llvm.cos.f32", type = !llvm.func<f32 (f32)>} : () -> ()
  "llvm.func"() ( {
  }) {linkage = 10 : i64, sym_name = "use", type = !llvm.func<void (f64)>} : () -> ()
  "llvm.func"() ( {
  }) {linkage = 10 : i64, sym_name = "llvm.sin.f128", type = !llvm.func<f128 (f128)>} : () -> ()
  "llvm.func"() ( {
  }) {linkage = 10 : i64, sym_name = "llvm.cos.f128", type = !llvm.func<f128 (f128)>} : () -> ()
  "module_terminator"() : () -> ()
}) : () -> ()
