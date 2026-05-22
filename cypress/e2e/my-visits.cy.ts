describe('My Visits', () => {
  it('shows all the parts', () => {
    cy.visit('/my-visits');

    cy.get('[data-component="library/tabber"]').should('exist');
    cy.get('svg.cell-map').should('exist');
    cy.contains('0 of 81');
    cy.get('div[data-test-selected-library]').should('exist');
  });
});
