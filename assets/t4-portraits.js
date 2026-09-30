(() => {
  const input = document.getElementById('t4-search');
  const category = document.getElementById('t4-category');
  if (!input || !category) return;
  const cards = Array.from(document.querySelectorAll('.t4-portrait'));
  const normalize = value => value.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLocaleLowerCase('fr');
  function update() {
    const terms = normalize(input.value).trim().split(/\s+/).filter(Boolean);
    let count = 0;
    cards.forEach(card => {
      const match = terms.every(term => normalize(card.dataset.search).includes(term)) && (!category.value || card.dataset.category === category.value);
      card.hidden = !match;
      if (match) count++;
    });
    document.getElementById('t4-result').textContent = `${count} portrait${count > 1 ? 's' : ''} sur ${cards.length}`;
    document.getElementById('t4-empty').hidden = count !== 0;
  }
  document.querySelector('.t4-controls').hidden = false;
  input.addEventListener('input', update);
  category.addEventListener('change', update);
  update();
})();
