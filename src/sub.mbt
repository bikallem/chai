///|
pub(all) struct SubDef[Msg] {
  key : String
  start : ((Msg) -> Unit) -> () -> Unit
}

///|
pub struct Sub[Msg] {
  subs : Array[SubDef[Msg]]
}

///|
pub fn[Msg] Sub::none() -> Sub[Msg] {
  { subs: [] }
}

///|
pub fn[Msg] Sub::batch(subs : Array[Sub[Msg]]) -> Sub[Msg] {
  let all : Array[SubDef[Msg]] = []
  for sub in subs {
    for s in sub.subs {
      all.push(s)
    }
  }
  { subs: all }
}

///|
pub fn[A, B] Sub::map(self : Sub[A], f : (A) -> B) -> Sub[B] {
  let new_subs : Array[SubDef[B]] = self.subs.map(fn(sd) {
    {
      key: sd.key,
      start: fn(dispatch : (B) -> Unit) { (sd.start)(fn(a) { dispatch(f(a)) }) },
    }
  })
  { subs: new_subs }
}

///|
pub fn[Msg] Sub::sub(
  key : String,
  start : ((Msg) -> Unit) -> () -> Unit,
) -> Sub[Msg] {
  { subs: [{ key, start }] }
}
