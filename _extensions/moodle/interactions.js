<script>
  document.addEventListener("DOMContentLoaded", function() {

  // --- MODUL 1: Click-to-Select (Gap Text) ---
  try {
    const dragExercises = document.querySelectorAll(".drag-exercise");
    dragExercises.forEach((ex) => {
      // Quarto turns *Word* into <em>Word</em>. We look for that tag.
      const originalHTML = ex.innerHTML;
  const parts = originalHTML.split(/(<em>.*?<\/em>)/g);

    let newHtml = '<div class="click-text">';
      let words = [];
      let wordIdCounter = 0;
      
      parts.forEach(part => {
        if (part.startsWith("<em>") && part.endsWith("</em>")) {
          const wordText = part.replace("<em>", "").replace("</em>", "");
      words.push({text: wordText, id: wordIdCounter++ });
      newHtml += `<span class="click-gap" data-answer="${wordText}"></span>`;
        } else {
        newHtml += part;
        }
      });

      // TRANSLATION: "Check" button
      newHtml += '</div><div class="click-pool"></div><button class="check-btn">Check</button>';
    ex.innerHTML = newHtml;

    let selectedWordBtn = null;
    const pool = ex.querySelector(".click-pool");
      
      words.sort(() => Math.random() - 0.5);

      words.forEach(w => {
        const btn = document.createElement("button");
    btn.textContent = w.text;
    btn.classList.add("pool-word");
    btn.dataset.id = w.id;
        
        btn.addEventListener("click", () => {
          if (btn.classList.contains("used")) return;
    if (selectedWordBtn) selectedWordBtn.classList.remove("selected");
    selectedWordBtn = btn;
    btn.classList.add("selected");
        });
    pool.appendChild(btn);
      });

    const gaps = ex.querySelectorAll(".click-gap");
      gaps.forEach(gap => {
      gap.addEventListener("click", () => {
        if (gap.classList.contains("filled")) {
          const currentId = gap.dataset.currentId;
          const originalBtn = pool.querySelector(`.pool-word[data-id="${currentId}"]`);
          if (originalBtn) originalBtn.classList.remove("used");

          gap.textContent = "";
          gap.classList.remove("filled", "correct", "wrong");
          delete gap.dataset.currentId;
          return;
        }
        if (selectedWordBtn) {
          gap.textContent = selectedWordBtn.textContent;
          gap.classList.add("filled");
          gap.dataset.currentId = selectedWordBtn.dataset.id;

          selectedWordBtn.classList.remove("selected");
          selectedWordBtn.classList.add("used");
          selectedWordBtn = null;
        }
      });
      });

      ex.querySelector(".check-btn").addEventListener("click", () => {
      gaps.forEach(gap => {
        if (!gap.classList.contains("filled")) return;
        if (gap.textContent.trim() === gap.dataset.answer.trim()) {
          gap.classList.add("correct");
          gap.classList.remove("wrong");
        } else {
          gap.classList.add("wrong");
          gap.classList.remove("correct");
        }
      });
      });
    });
  } catch (e) {console.error("Error in Drag Module:", e); }


    // --- MODUL 2: Flip-Cards ---
    try {
    const cards = document.querySelectorAll(".flip-card");
    cards.forEach(card => {
      const title = card.querySelector("h4");
    if(!title) return;

    const content = card.innerHTML.replace(title.outerHTML, "");

    card.innerHTML = `
    <div class="flip-inner">
      <div class="flip-front">
        <div class="flip-content">
          <span class="flip-icon">↻</span>
          <h4>${title.innerHTML}</h4>
        </div>
      </div>
      <div class="flip-back">
        <div class="flip-content">${content}</div>
      </div>
    </div>
    `;
      
      card.addEventListener("click", () => {
      card.classList.toggle("flipped");
      });
    });
  } catch (e) {console.error("Error in Flip-Card Module:", e); }


    // --- MODUL 3: Quick-Check (Quiz) ---
    try {
      document.querySelectorAll(".quick-check").forEach(qc => {
        const listItems = qc.querySelectorAll("li");
        const explanationBlock = qc.querySelector("blockquote");
        const explanation = explanationBlock ? explanationBlock.innerHTML : "";

        // TRANSLATION: Fallback title
        let questionText = "Test your knowledge:";
        const p = qc.querySelector("p");
        if (p && p !== explanationBlock) questionText = p.innerHTML;
        else if (qc.firstChild.nodeType === 3) questionText = qc.firstChild.textContent;

        let html = `<div class="qc-question">${questionText}</div><div class="qc-options">`;

        listItems.forEach(li => {
          const isCorrect = li.querySelector("strong") !== null;
          const text = li.textContent;
          html += `<button class="qc-btn" data-correct="${isCorrect}">${text}</button>`;
        });

        html += `</div><div class="qc-feedback" style="display:none;">${explanation}</div>`;
        qc.innerHTML = html;

        const btns = qc.querySelectorAll(".qc-btn");
        const feedback = qc.querySelector(".qc-feedback");

        btns.forEach(btn => {
          btn.addEventListener("click", () => {
            btns.forEach(b => b.disabled = true);

            if (btn.dataset.correct === "true") {
              btn.classList.add("correct");
              feedback.classList.add("show-correct");
              // TRANSLATION: Correct
              feedback.innerHTML = "<strong>Correct!</strong> " + feedback.innerHTML;
            } else {
              btn.classList.add("wrong");
              btns.forEach(b => { if (b.dataset.correct === "true") b.classList.add("correct-dimmed"); });
              feedback.classList.add("show-wrong");
              // TRANSLATION: Not quite (better than Wrong)
              feedback.innerHTML = "<strong>Not quite.</strong> " + feedback.innerHTML;
            }
            feedback.style.display = "block";
          });
        });
      });
  } catch (e) {console.error("Error in Quiz Module:", e); }

});
</script>