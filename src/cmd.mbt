///|
struct Cmd[Msg] {
  tasks : Array[((Msg) -> Unit) -> Unit]
}

///|
pub fn[Msg] Cmd::none() -> Cmd[Msg] {
  { tasks: [] }
}

///|
pub fn[Msg] Cmd::batch(cmds : Array[Cmd[Msg]]) -> Cmd[Msg] {
  let tasks : Array[((Msg) -> Unit) -> Unit] = []
  for cmd in cmds {
    for task in cmd.tasks {
      tasks.push(task)
    }
  }
  { tasks, }
}

///|
pub fn[A, B] Cmd::map(self : Cmd[A], f : (A) -> B) -> Cmd[B] {
  let new_tasks : Array[((B) -> Unit) -> Unit] = self.tasks.map(fn(task) {
    fn(dispatch : (B) -> Unit) { task(fn(a) { dispatch(f(a)) }) }
  })
  { tasks: new_tasks }
}

///|
pub fn[Msg] Cmd::task(task : ((Msg) -> Unit) -> Unit) -> Cmd[Msg] {
  { tasks: [task] }
}

///|
/// Send a message into a child component's update loop via its Handle.
pub fn[CMsg, Msg] Cmd::send(handle : Handle[CMsg], msg : CMsg) -> Cmd[Msg] {
  { tasks: [fn(_dispatch) { (handle.dispatch.val)(msg) }] }
}

///|
/// Dispatch a message after a delay in milliseconds.
pub fn[Msg] Cmd::after(ms : Int, msg : Msg) -> Cmd[Msg] {
  Cmd::task(fn(dispatch) { set_timeout_ffi(fn() { dispatch(msg) }, ms) })
}

///|
extern "js" fn set_timeout_ffi(
  f : () -> Unit,
  ms : Int,
) -> Unit = "(f, ms) => setTimeout(f, ms)"
