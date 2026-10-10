# Decision: follow-up scope after goal c1ab3a20

- Date: 2026-10-10
- Decision: do option B. Fix only W3 and m9 from the L3 review.
  - W3: selector test fakes accept any keyword. A renamed bbox: or deadline: keyword is not caught.
  - m9: app.rb does not pass deadline: to Selector#select. The OSM request runs outside the 29 second card deadline.
- Not in scope: W1, W2, W4, W5. The user did not choose them.
- Policy: .reek.yml may hold reasonable exclusions. Each exclusion needs a reason comment.
- Open: the grapheme gap in public/app.js waits for review. Do not change it.
