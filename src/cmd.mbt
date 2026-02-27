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
