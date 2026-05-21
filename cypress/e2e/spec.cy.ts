describe('My First Test', () => {
  it('Visits the Libraries page', () => {
    cy.visit('/libraries');

    cy.contains('81 libraries loaded');
  });
});
