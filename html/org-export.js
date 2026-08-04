// Dark-mode toggle for the Org HTML export theme (html/org-export.css).
// Manual only — deliberately does not follow prefers-color-scheme.
(function () {
  var stored = localStorage.getItem("org-export-theme");
  var theme = stored === "dark" ? "dark" : "light";

  // Set the attribute immediately (before the header bar exists) so a
  // saved dark preference doesn't flash light on load.
  document.documentElement.setAttribute("data-theme", theme);

  function apply(next) {
    theme = next;
    document.documentElement.setAttribute("data-theme", theme);
    var btn = document.getElementById("theme-toggle");
    if (btn) btn.innerHTML = theme === "dark" ? "&#9728;" : "&#9680;";
  }

  document.addEventListener("DOMContentLoaded", function () {
    apply(theme); // sync the toggle button's icon now that it exists
    var btn = document.getElementById("theme-toggle");
    if (!btn) return;
    btn.addEventListener("click", function () {
      var next = theme === "dark" ? "light" : "dark";
      localStorage.setItem("org-export-theme", next);
      apply(next);
    });
  });
})();
