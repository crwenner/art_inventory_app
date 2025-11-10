/* =========================================================
   Art Inventory App — Basic Frontend Scripts
   Provides table filtering, toggle behavior, and confirmations
   ========================================================= */

document.addEventListener("DOMContentLoaded", function () {
  // --- Elements ---
  const toggleButton = document.getElementById("toggleSold");
  const soldRows = document.querySelectorAll("tr[data-sold='true']");
  const deleteForms = document.querySelectorAll("form.delete-form");

  // --- Toggle sold items visibility ---
  if (toggleButton) {
    toggleButton.addEventListener("click", () => {
      const showingSold = toggleButton.dataset.showing === "true";

      soldRows.forEach((row) => {
        row.style.display = showingSold ? "none" : "";
      });

      toggleButton.dataset.showing = (!showingSold).toString();
      toggleButton.textContent = showingSold
        ? "Show Sold Items"
        : "Hide Sold Items";
    });
  }

  // --- Delete confirmation ---
  deleteForms.forEach((form) => {
    form.addEventListener("submit", (e) => {
      const confirmed = confirm("Are you sure you want to delete this item?");
      if (!confirmed) e.preventDefault();
    });
  });

  // --- Optional: Flash auto-hide ---
  const flash = document.querySelector(".notice, .error");
  if (flash) {
    setTimeout(() => {
      flash.style.transition = "opacity 0.6s ease";
      flash.style.opacity = "0";
      setTimeout(() => flash.remove(), 600);
    }, 4000);
  }
});

