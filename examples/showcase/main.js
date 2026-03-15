const examples = [
  {
    id: "todo",
    title: "Todo",
    desc: "TodoMVC-style app with input, filtering, and keyed list diffing",
  },
  {
    id: "counters",
    title: "Counters",
    desc: "Encapsulated counter components with parent-to-child messaging via Handle",
  },
  {
    id: "clock",
    title: "Clock",
    desc: "Stopwatch with Sub::every, Sub::on_key_down, and Cmd::after",
  },
  {
    id: "router",
    title: "Router",
    desc: "Hash-based routing with Sub::on_hash_change and hash_link",
  },
  {
    id: "fetch",
    title: "Fetch",
    desc: "HTTP requests with Cmd::http_get",
  },
  {
    id: "canvas",
    title: "Canvas",
    desc: "Canvas drawing with mouse event subscriptions",
  },
];

const BASE = import.meta.env.BASE_URL;
const sidebar = document.getElementById("sidebar");
const frame = document.getElementById("example-frame");
const titleEl = document.getElementById("example-title");
const descEl = document.getElementById("example-desc");

function select(id) {
  const ex = examples.find((e) => e.id === id);
  if (!ex) return;

  titleEl.textContent = ex.title;
  descEl.textContent = ex.desc;
  frame.src = `${BASE}examples/${ex.id}.html`;

  document.querySelectorAll("[data-example]").forEach((btn) => {
    const isActive = btn.dataset.example === id;
    btn.classList.toggle("bg-stone-100", isActive);
    btn.classList.toggle("text-stone-900", isActive);
    btn.classList.toggle("font-medium", isActive);
    btn.classList.toggle("text-stone-600", !isActive);
  });

  history.replaceState(null, "", `${BASE}#${id}`);
}

for (const ex of examples) {
  const btn = document.createElement("button");
  btn.dataset.example = ex.id;
  btn.textContent = ex.title;
  btn.className =
    "text-left px-3 py-1.5 rounded-md text-sm transition-colors hover:bg-stone-50 cursor-pointer";
  btn.addEventListener("click", () => select(ex.id));
  sidebar.appendChild(btn);
}

const initial = location.hash.slice(1) || examples[0].id;
select(initial);
